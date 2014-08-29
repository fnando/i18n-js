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
      expected_files = %w(en de fr).map { |locale| "tmp/i18n-js/bits.#{locale}.js" }
      result.keys.should eql(expected_files)

      %w{en fr}.each do |lang|
        result["tmp/i18n-js/bits.#{lang}.js"].keys.should eql([lang.to_sym])
        result["tmp/i18n-js/bits.#{lang}.js"][lang.to_sym].keys.sort.should eql([:date, :number])
      end
    end

    context "fallbacks" do
      it "exports without fallback when disabled" do
        set_config "js_file_per_locale_without_fallbacks.yml"

        result = I18n::JS.translation_segments
        result["tmp/i18n-js/fr.js"][:fr][:fallback_test].should eql(nil)
      end

      it "exports with default_locale as fallback when enabled" do
        set_config "js_file_per_locale_with_fallbacks_enabled.yml"

        result = I18n::JS.translation_segments
        result["tmp/i18n-js/fr.js"][:fr][:fallback_test].should eql("Success")
      end

      it "exports with given locale as fallback" do
        set_config "js_file_per_locale_with_fallbacks_as_locale.yml"

        result = I18n::JS.translation_segments
        result["tmp/i18n-js/fr.js"][:fr][:fallback_test].should eql("Erfolg")
      end

      context "with I18n::Fallbacks enabled" do
        let(:backend_with_fallbacks) { backend_class_with_fallbacks.new }

        before do
          I18n.backend = backend_with_fallbacks
          I18n.fallbacks[:fr] = [:de, :en]
        end
        after { I18n.backend = I18n::Backend::Simple.new }

        it "exports with defined locale as fallback when enabled" do
          set_config "js_file_per_locale_with_fallbacks_enabled.yml"

          result = I18n::JS.translation_segments
          result["tmp/i18n-js/fr.js"][:fr][:fallback_test].should eql("Erfolg")
        end

        it "exports with Fallbacks as Hash" do
          set_config "js_file_per_locale_with_fallbacks_as_hash.yml"

          result = I18n::JS.translation_segments
          result["tmp/i18n-js/fr.js"][:fr][:fallback_test].should eql("Erfolg")
        end
      end
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
      I18n::JS.export_dir.should eql("public/javascripts")
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
