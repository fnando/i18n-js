require "spec_helper"

describe I18n::JS do
  context "exporting" do
    before do
      I18n::JS.stub :export_dir => temp_path
    end

    it "exports messages to default path when configuration file doesn't exist" do
      I18n::JS.export
      file_should_exist "translations.js"
    end

    it "exports messages using custom output path" do
      set_config "custom_path.yml"
      expect(I18n::JS).to receive(:save).with(translations, "tmp/i18n-js/all.js")
      I18n::JS.export
    end

    it "sets default scope to * when not specified" do
      set_config "no_scope.yml"
      expect(I18n::JS).to receive(:save).with(translations, "tmp/i18n-js/no_scope.js")
      I18n::JS.export
    end

    it "exports to multiple files" do
      set_config "multiple_files.yml"
      I18n::JS.export

      file_should_exist "all.js"
      file_should_exist "tudo.js"
    end

    it "ignores an empty config file" do
      set_config "no_config.yml"
      I18n::JS.export

      file_should_exist "translations.js"
    end

    it "exports to a JS file per available locale" do
      set_config "js_file_per_locale.yml"
      I18n::JS.export

      file_should_exist "en.js"
    end

    it "exports with multiple conditions" do
      set_config "multiple_conditions.yml"
      I18n::JS.export

      file_should_exist "bitsnpieces.js"
    end
  end

  context "filters" do
    it "filters translations using scope *.date.formats" do
      result = I18n::JS.filter(translations, "*.date.formats")
      expect(result[:en][:date].keys).to eql([:formats])
      expect(result[:fr][:date].keys).to eql([:formats])
    end

    it "filters translations using scope [*.date.formats, *.number.currency.format]" do
      result = I18n::JS.scoped_translations(["*.date.formats", "*.number.currency.format"])
      expect(result[:en].keys.collect(&:to_s).sort).to eql(%w[ date number ])
      expect(result[:fr].keys.collect(&:to_s).sort).to eql(%w[ date number ])
    end

    it "filters translations using multi-star scope" do
      result = I18n::JS.scoped_translations("*.*.formats")

      expect(result[:en].keys.collect(&:to_s).sort).to eql(%w[ date time ])
      expect(result[:fr].keys.collect(&:to_s).sort).to eql(%w[ date time ])

      expect(result[:en][:date].keys).to eql([:formats])
      expect(result[:en][:time].keys).to eql([:formats])

      expect(result[:fr][:date].keys).to eql([:formats])
      expect(result[:fr][:time].keys).to eql([:formats])
    end

    it "filters translations using alternated stars" do
      result = I18n::JS.scoped_translations("*.admin.*.title")

      expect(result[:en][:admin].keys.collect(&:to_s).sort).to eql(%w[ edit show ])
      expect(result[:fr][:admin].keys.collect(&:to_s).sort).to eql(%w[ edit show ])

      expect(result[:en][:admin][:show][:title]).to eql("Show")
      expect(result[:fr][:admin][:show][:title]).to eql("Visualiser")

      expect(result[:en][:admin][:edit][:title]).to eql("Edit")
      expect(result[:fr][:admin][:edit][:title]).to eql("Editer")
    end
  end

  context "general" do
    it "sets export directory" do
      expect(I18n::JS.export_dir).to eql("public/javascripts")
    end

    it "sets empty hash as configuration when no file is found" do
      expect(I18n::JS.config?).to be_false
      expect(I18n::JS.config).to eql({})
    end
  end

  context "hash merging" do
    it "performs a deep merge" do
      target = {:a => {:b => 1}}
      result = I18n::JS.deep_merge(target, {:a => {:c => 2}})

      expect(result[:a]).to eql({:b => 1, :c => 2})
    end

    it "performs a banged deep merge" do
      target = {:a => {:b => 1}}
      I18n::JS.deep_merge!(target, {:a => {:c => 2}})

      expect(target[:a]).to eql({:b => 1, :c => 2})
    end
  end
end
