require "spec_helper"

describe I18n::JS do
  before do
    I18n.load_path = [File.dirname(__FILE__) + "/fixtures/locales.yml"]
  end

  around do
    FileUtils.rm_rf("/tmp/i18n-js")
  end

  context "exporting" do
    before do
      I18n::JS.stub :export_dir => "/tmp/i18n-js"
    end

    it "exports messages to default path when configuration file doesn't exist" do
      I18n::JS.export
      File.join(I18n::JS.export_dir, "translations.js").should be_file
    end

    it "exports messages using custom output path" do
      set_config "custom_path.yml"
      I18n::JS.should_receive(:save).with(translations, "public/javascripts/translations/all.js")
      I18n::JS.export
    end

    it "sets default scope to * when not specified" do
      set_config "no_scope.yml"
      I18n::JS.should_receive(:save).with(translations, "public/javascripts/no_scope.js")
      I18n::JS.export
    end

    it "exports to multiple files" do
      set_config "multiple_files.yml"
      I18n::JS.export

      File.should be_file(Rails.root.join("public/javascripts/all.js"))
      File.should be_file(Rails.root.join("public/javascripts/tudo.js"))
    end

    it "ignores an empty config file" do
      set_config "no_config.yml"
      I18n::JS.export
      File.should be_file("/tmp/i18n-js/translations.js")
    end

    it "exports to a JS file per available locale" do
      set_config "js_file_per_locale.yml"
      I18n::JS.export

      File.should be_file("/tmp/i18n-js/en.js")
    end

    it "exports with multiple conditions" do
      set_config "multiple_conditions.yml"
      I18n::JS.export

      File.should be_file("/tmp/i18n-js/bitsnpieces.js")
    end
  end

  context "filters" do
    it "filters translations using scope *.date.formats" do
      result = I18n::JS.filter(translations, "*.date.formats")
      result[:en][:date].keys.should eql([:formats])
      result[:fr][:date].keys.should eql([:formats])
    end

    it "filters translations using scope [*.date.formats, *.number.currency.format]" do
      result = I18n::JS.scoped_translations(["*.date.formats", "*.number.currency.format"])
      result[:en].keys.collect(&:to_s).sort.should eql(%w[ date number ])
      result[:fr].keys.collect(&:to_s).sort.should eql(%w[ date number ])
    end

    it "filters translations using multi-star scope" do
      result = I18n::JS.scoped_translations("*.*.formats")

      result[:en].keys.collect(&:to_s).sort.should eql(%w[ date time ])
      result[:fr].keys.collect(&:to_s).sort.should eql(%w[ date time ])

      result[:en][:date].keys.should eql([:formats])
      result[:en][:time].keys.should eql([:formats])

      result[:fr][:date].keys.should eql([:formats])
      result[:fr][:time].keys.should eql([:formats])
    end

    it "filters translations using alternated stars" do
      result = I18n::JS.scoped_translations("*.admin.*.title")

      result[:en][:admin].keys.collect(&:to_s).sort.should eql(%w[ edit show ])
      result[:fr][:admin].keys.collect(&:to_s).sort.should eql(%w[ edit show ])

      result[:en][:admin][:show][:title].should eql("Show")
      result[:fr][:admin][:show][:title].should eql("Visualiser")

      result[:en][:admin][:edit][:title].should eql("Edit")
      result[:fr][:admin][:edit][:title].should eql("Editer")
    end
  end

  context "general" do
    it "sets export directory" do
      I18n::JS.export_dir.should eql("public/javascripts")
    end

    it "sets empty hash as configuration when no file is found" do
      I18n::JS.config?.should be_false
      I18n::JS.config.should eql({})
    end
  end

  context "hash merging" do
    it "performs a deep merge" do
      target = {:a => {:b => 1}}
      result = I18n::JS.deep_merge(target, {:a => {:c => 2}})

      result[:a].should eql({:b => 1, :c => 2})
    end

    it "performs a banged deep merge" do
      target = {:a => {:b => 1}}
      I18n::JS.deep_merge!(target, {:a => {:c => 2}})

      target[:a].should eql({:b => 1, :c => 2})
    end
  end

  private
  # Set the configuration as the current one
  def set_config(path)
    config = HashWithIndifferentAccess.new(YAML.load_file(File.dirname(__FILE__) + "/fixtures/#{path}"))
    I18n::JS.stub(:config? => true, :config => config)
  end

  # Shortcut to I18n::JS.translations
  def translations
    I18n::JS.translations
  end
end

