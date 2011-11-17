require "spec_helper"

if File.basename(Rails.root) != "tmp"
  abort <<-TXT
\e[31;5m
WARNING: That will remove your project!
Please go to #{File.expand_path(File.dirname(__FILE__) + "/..")} and run `rake spec`\e[0m
TXT
end

describe SimplesIdeias::I18n do
  before do
    # Remove temporary directory if already present
    FileUtils.rm_r(Rails.root) if File.exist?(Rails.root)

    # Create temporary directory to test the files generation
    %w( config public/javascripts ).each do |path|
      FileUtils.mkdir_p Rails.root.join(path)
    end

    # Overwrite defaut locales path to use fixtures
    I18n.load_path = [File.dirname(__FILE__) + "/resources/locales.yml"]
  end

  after do
    # Remove temporary directory
    FileUtils.rm_r(Rails.root)
  end

  it "copies the configuration file" do
    File.should_not be_file(SimplesIdeias::I18n.config_file)
    SimplesIdeias::I18n.setup!
    File.should be_file(SimplesIdeias::I18n.config_file)
  end

  it "keeps existing configuration file" do
    File.open(SimplesIdeias::I18n.config_file, "w+") {|f| f << "ORIGINAL"}
    SimplesIdeias::I18n.setup!

    File.read(SimplesIdeias::I18n.config_file).should == "ORIGINAL"
  end

  it "copies JavaScript library" do
    path = Rails.root.join("public/javascripts/i18n.js")

    File.should_not be_file(path)
    SimplesIdeias::I18n.setup!
    File.should be_file(path)
  end

  it "loads configuration file" do
    set_config "default.yml"
    SimplesIdeias::I18n.setup!

    SimplesIdeias::I18n.config?.should be_true
    SimplesIdeias::I18n.config.should be_kind_of(HashWithIndifferentAccess)
    SimplesIdeias::I18n.config.should_not be_empty
  end

  it "sets empty hash as configuration when no file is found" do
    SimplesIdeias::I18n.config?.should be_false
    SimplesIdeias::I18n.config.should == {}
  end

  it "exports messages to default path when configuration file doesn't exist" do
    SimplesIdeias::I18n.export!
    Rails.root.join(SimplesIdeias::I18n.export_dir, "translations.js").should be_file
  end

  it "exports messages using custom output path" do
    set_config "custom_path.yml"
    SimplesIdeias::I18n.should_receive(:save).with(translations, "public/javascripts/translations/all.js")
    SimplesIdeias::I18n.export!
  end

  it "sets default scope to * when not specified" do
    set_config "no_scope.yml"
    SimplesIdeias::I18n.should_receive(:save).with(translations, "public/javascripts/no_scope.js")
    SimplesIdeias::I18n.export!
  end

  it "exports to multiple files" do
    set_config "multiple_files.yml"
    SimplesIdeias::I18n.export!

    File.should be_file(Rails.root.join("public/javascripts/all.js"))
    File.should be_file(Rails.root.join("public/javascripts/tudo.js"))
  end

  it "ignores an empty config file" do
    set_config "no_config.yml"
    SimplesIdeias::I18n.export!
    Rails.root.join(SimplesIdeias::I18n.export_dir, "translations.js").should be_file
  end

  it "exports to a JS file per available locale" do
    set_config "js_file_per_locale.yml"
    SimplesIdeias::I18n.export!

    File.should be_file(Rails.root.join("public/javascripts/i18n/en.js"))
  end

  it "exports with multiple conditions" do
    set_config "multiple_conditions.yml"
    SimplesIdeias::I18n.export!
    File.should be_file(Rails.root.join("public/javascripts/bitsnpieces.js"))
  end

  it "filters translations using scope *.date.formats" do
    result = SimplesIdeias::I18n.filter(translations, "*.date.formats")
    result[:en][:date].keys.should == [:formats]
    result[:fr][:date].keys.should == [:formats]
  end

  it "filters translations using scope [*.date.formats, *.number.currency.format]" do
    result = SimplesIdeias::I18n.scoped_translations(["*.date.formats", "*.number.currency.format"])
    result[:en].keys.collect(&:to_s).sort.should == %w[ date number ]
    result[:fr].keys.collect(&:to_s).sort.should == %w[ date number ]
  end

  it "filters translations using multi-star scope" do
    result = SimplesIdeias::I18n.scoped_translations("*.*.formats")

    result[:en].keys.collect(&:to_s).sort.should == %w[ date time ]
    result[:fr].keys.collect(&:to_s).sort.should == %w[ date time ]

    result[:en][:date].keys.should == [:formats]
    result[:en][:time].keys.should == [:formats]

    result[:fr][:date].keys.should == [:formats]
    result[:fr][:time].keys.should == [:formats]
  end

  it "filters translations using alternated stars" do
    result = SimplesIdeias::I18n.scoped_translations("*.admin.*.title")

    result[:en][:admin].keys.collect(&:to_s).sort.should == %w[ edit show ]
    result[:fr][:admin].keys.collect(&:to_s).sort.should == %w[ edit show ]

    result[:en][:admin][:show][:title].should == "Show"
    result[:fr][:admin][:show][:title].should == "Visualiser"

    result[:en][:admin][:edit][:title].should == "Edit"
    result[:fr][:admin][:edit][:title].should == "Editer"
  end

  it "performs a deep merge" do
    target = {:a => {:b => 1}}
    result = SimplesIdeias::I18n.deep_merge(target, {:a => {:c => 2}})

    result[:a].should == {:b => 1, :c => 2}
  end

  it "performs a banged deep merge" do
    target = {:a => {:b => 1}}
    SimplesIdeias::I18n.deep_merge!(target, {:a => {:c => 2}})

    target[:a].should == {:b => 1, :c => 2}
  end

  it "updates the javascript library" do
    FakeWeb.register_uri(:get, "https://raw.github.com/fnando/i18n-js/master/vendor/assets/javascripts/i18n.js", :body => "UPDATED")

    SimplesIdeias::I18n.setup!
    SimplesIdeias::I18n.update!
    File.read(SimplesIdeias::I18n.javascript_file).should == "UPDATED"
  end

  describe "#export_dir" do
    it "detects asset pipeline support" do
      SimplesIdeias::I18n.stub :has_asset_pipeline? => true
      SimplesIdeias::I18n.export_dir == "vendor/assets/javascripts"
    end

    it "detects older Rails" do
      SimplesIdeias::I18n.stub :has_asset_pipeline? => false
      SimplesIdeias::I18n.export_dir.to_s.should == "public/javascripts"
    end
  end

  describe "#has_asset_pipeline?" do
    it "detects support" do
      Rails.stub_chain(:configuration, :assets, :enabled => true)
      SimplesIdeias::I18n.should have_asset_pipeline
    end

    it "skips support" do
      SimplesIdeias::I18n.should_not have_asset_pipeline
    end
  end

  private
  # Set the configuration as the current one
  def set_config(path)
    config = HashWithIndifferentAccess.new(YAML.load_file(File.dirname(__FILE__) + "/resources/#{path}"))
    SimplesIdeias::I18n.stub(:config? => true)
    SimplesIdeias::I18n.stub(:config => config)
  end

  # Shortcut to SimplesIdeias::I18n.translations
  def translations
    SimplesIdeias::I18n.translations
  end
end

