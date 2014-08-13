require "spec_helper"

describe I18n::JS do
  describe '.config_file_path' do
    let(:default_path) { I18n::JS::DEFAULT_CONFIG_PATH }
    let(:new_path) { File.join("tmp", default_path) }

    subject { described_class.config_file_path }

    context "when it is not set" do
      it { should eq default_path }
    end
    context "when it is set already" do
      before { described_class.config_file_path = new_path }

      it { should eq new_path }
    end
  end

  context "exporting" do
    before do
      I18n::JS.stub :default_export_dir_path => temp_path
    end

    it "exports messages to default path when configuration file doesn't exist" do
      I18n::JS.export
      file_should_exist "translations.js"
    end

    it "exports messages using custom output path" do
      set_config "custom_path.yml"
      I18n::JS.should_receive(:save).with(translations, "tmp/i18n-js/all.js")
      I18n::JS.export
    end

    it "sets default scope to * when not specified" do
      set_config "no_scope.yml"
      I18n::JS.should_receive(:save).with(translations, "tmp/i18n-js/no_scope.js")
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

    it "exports with multiple conditions to a JS file per available locale" do
      allow(::I18n).to receive(:available_locales){ [:en, :fr] }

      set_config "multiple_conditions_per_locale.yml"

      result = I18n::JS.translation_segments
      result.keys.should eql(["tmp/i18n-js/bits.en.js", "tmp/i18n-js/bits.fr.js"])

      %w{en fr}.each do |lang|
        result["tmp/i18n-js/bits.#{lang}.js"].keys.should eql([lang.to_sym])
        result["tmp/i18n-js/bits.#{lang}.js"][lang.to_sym].keys.sort.should eql([:date, :number])
      end
    end

    it "calls .export_i18n_js" do
      allow(described_class).to receive(:export_i18n_js)
      I18n::JS.export
      expect(described_class).to have_received(:export_i18n_js).once
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

  context "I18n.available_locales" do
    context "when I18n.available_locales is not set" do
      it "should allow all locales" do
        result = I18n::JS.scoped_translations("*.admin.*.title")

        result[:en][:admin][:show][:title].should eql("Show")
        result[:fr][:admin][:show][:title].should eql("Visualiser")
        result[:ja][:admin][:show][:title].should eql("Ignore me")
      end
    end

    context "when I18n.available_locales is set" do
      before { allow(::I18n).to receive(:available_locales){ [:en, :fr] } }

      it "should ignore non-valid locales" do
        result = I18n::JS.scoped_translations("*.admin.*.title")

        result[:en][:admin][:show][:title].should eql("Show")
        result[:fr][:admin][:show][:title].should eql("Visualiser")
        result.keys.include?(:ja).should eql(false)
      end
    end
  end

  context "general" do
    it "sets export directory" do
      I18n::JS.default_export_dir_path.should eql("public/javascripts")
    end

    it "sets empty hash as configuration when no file is found" do
      I18n::JS.config?.should eql(false)
      I18n::JS.config.should eql({})
    end

    it "executes erb in config file" do
      set_config "erb.yml"

      config_entry = I18n::JS.config["translations"].first
      config_entry["only"].should eq("*.date.formats")
    end
  end


  describe "i18n.js exporting" do
    describe ".export_i18n_js" do
      before do
        allow(FileUtils).to receive(:mkdir_p).and_call_original
        allow(FileUtils).to receive(:cp).and_call_original

        described_class.stub(:export_i18n_js_dir_path).and_return(export_i18n_js_dir_path)
        I18n::JS.export_i18n_js
      end

      context 'when .export_i18n_js_dir_path returns something' do
        let(:export_i18n_js_dir_path) { temp_path }

        it "does create the folder before copying" do
          expect(FileUtils).to have_received(:mkdir_p).with(export_i18n_js_dir_path).once
        end
        it "does copy the file with FileUtils.cp" do
          expect(FileUtils).to have_received(:cp).once
        end
        it "exports the file" do
          File.should be_file(File.join(I18n::JS.export_i18n_js_dir_path, "i18n.js"))
        end
      end

      context 'when .export_i18n_js_dir_path is set to nil' do
        let(:export_i18n_js_dir_path) { nil }

        it "does NOT create the folder before copying" do
          expect(FileUtils).to_not have_received(:mkdir_p)
        end
        it "does NOT copy the file with FileUtils.cp" do
          expect(FileUtils).to_not have_received(:cp)
        end
      end
    end


    describe '.export_i18n_js_dir_path' do
      let(:default_path) { I18n::JS.default_export_dir_path }
      let(:new_path) { File.join("tmp", default_path) }
      before { described_class.remove_instance_variable(:@export_i18n_js_dir_path) }

      subject { described_class.export_i18n_js_dir_path }

      context "when it is not set" do
        it { should eq default_path }
      end
      context "when it is set to another path already" do
        before { described_class.export_i18n_js_dir_path = new_path }

        it { should eq new_path }
      end
      context "when it is set to nil already" do
        before { described_class.export_i18n_js_dir_path = nil }

        it { should be_nil }
      end
    end
  end
end

describe I18n::JS::Dependencies, ".sprockets_supports_register_preprocessor?" do

  subject { described_class.sprockets_supports_register_preprocessor? }

  context 'when Sprockets is available to register preprocessors' do
    let!(:sprockets_double) do
      class_double('Sprockets').as_stubbed_const(register_processor: true).tap do |double|
        allow(double).to receive(:respond_to?).with(:register_preprocessor).and_return(true)
      end
    end

    it { is_expected.to be_truthy }
    it 'calls respond_to? with register_preprocessor on Sprockets' do
      expect(sprockets_double).to receive(:respond_to?).with(:register_preprocessor).and_return(true)
      subject
    end
  end

  context 'when Sprockets is NOT available to register preprocessors' do
    let!(:sprockets_double) do
      class_double('Sprockets').as_stubbed_const(register_processor: true).tap do |double|
        allow(double).to receive(:respond_to?).with(:register_preprocessor).and_return(false)
      end
    end

    it { is_expected.to be_falsy }
    it 'calls respond_to? with register_preprocessor on Sprockets' do
      expect(sprockets_double).to receive(:respond_to?).with(:register_preprocessor).and_return(false)
      subject
    end
  end

  context 'when Sprockets is missing' do
    before do
      hide_const('Sprockets')
      expect { Sprockets }.to raise_error(NameError)
    end

    it { is_expected.to be_falsy }
  end

end

describe I18n::JS::Utils do

  describe ".strip_keys_with_nil_values" do
    subject { described_class.strip_keys_with_nil_values(input_hash) }

    context 'when input_hash does NOT contain nil value' do
      let(:input_hash) { {a: 1, b: { c: 2 }} }
      let(:expected_hash) { input_hash }

      it 'returns the original input' do
        is_expected.to eq expected_hash
      end
    end
    context 'when input_hash does contain nil value' do
      let(:input_hash) { {a: 1, b: { c: 2, d: nil }, e: { f: nil }} }
      let(:expected_hash) { {a: 1, b: { c: 2 }, e: {}} }

      it 'returns the original input with nil values removed' do
        is_expected.to eq expected_hash
      end
    end
  end

  context "hash merging" do
    it "performs a deep merge" do
      target = {:a => {:b => 1}}
      result = described_class.deep_merge(target, {:a => {:c => 2}})

      result[:a].should eql({:b => 1, :c => 2})
    end

    it "performs a banged deep merge" do
      target = {:a => {:b => 1}}
      described_class.deep_merge!(target, {:a => {:c => 2}})

      target[:a].should eql({:b => 1, :c => 2})
    end
  end

end
