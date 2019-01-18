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
      stub_const('I18n::JS::DEFAULT_EXPORT_DIR_PATH', temp_path)
    end

    it "exports messages to default path when configuration file doesn't exist" do
      I18n::JS.export
      file_should_exist "translations.js"
    end

    it "exports messages using custom output path" do
      set_config "custom_path.yml"
      allow(I18n::JS::Segment).to receive(:new).with("tmp/i18n-js/all.js", translations, {js_extend: true, sort_translation_keys: true, json_only: false}).and_call_original
      allow_any_instance_of(I18n::JS::Segment).to receive(:save!).with(no_args)
      I18n::JS.export
    end

    it "sets default scope to * when not specified" do
      set_config "no_scope.yml"
      allow(I18n::JS::Segment).to receive(:new).with("tmp/i18n-js/no_scope.js", translations, {js_extend: true, sort_translation_keys: true, json_only: false}).and_call_original
      allow_any_instance_of(I18n::JS::Segment).to receive(:save!).with(no_args)
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
      file_should_exist "fr.js"

      en_output = File.read(File.join(I18n::JS.export_i18n_js_dir_path, "en.js"))
      expect(en_output).to eq(<<EOS
I18n.translations || (I18n.translations = {});
I18n.translations["en"] = I18n.extend((I18n.translations["en"] || {}), {"admin":{"edit":{"title":"Edit"},"show":{"note":"more details","title":"Show"}},"date":{"abbr_day_names":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"abbr_month_names":[null,"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"day_names":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],"formats":{"default":"%Y-%m-%d","long":"%B %d, %Y","short":"%b %d"},"month_names":[null,"January","February","March","April","May","June","July","August","September","October","November","December"]}});
EOS
)
      fr_output = File.read(File.join(I18n::JS.export_i18n_js_dir_path, "fr.js"))
      expect(fr_output).to eq(<<EOS
I18n.translations || (I18n.translations = {});
I18n.translations["fr"] = I18n.extend((I18n.translations["fr"] || {}), {"admin":{"edit":{"title":"Editer"},"show":{"note":"plus de détails","title":"Visualiser"}},"date":{"abbr_day_names":["dim","lun","mar","mer","jeu","ven","sam"],"abbr_month_names":[null,"jan.","fév.","mar.","avr.","mai","juin","juil.","août","sept.","oct.","nov.","déc."],"day_names":["dimanche","lundi","mardi","mercredi","jeudi","vendredi","samedi"],"formats":{"default":"%d/%m/%Y","long":"%e %B %Y","long_ordinal":"%e %B %Y","only_day":"%e","short":"%e %b"},"month_names":[null,"janvier","février","mars","avril","mai","juin","juillet","août","septembre","octobre","novembre","décembre"]}});
EOS
)
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
      expect(result.map(&:file)).to eql(["tmp/i18n-js/bits.%{locale}.js"])

      result.map(&:save!)

      en_output = File.read(File.join(I18n::JS.export_i18n_js_dir_path, "bits.en.js"))
      expect(en_output).to eq(<<EOS
I18n.translations || (I18n.translations = {});
I18n.translations["en"] = I18n.extend((I18n.translations["en"] || {}), {"date":{"formats":{"default":"%Y-%m-%d","long":"%B %d, %Y","short":"%b %d"}},"number":{"currency":{"format":{"delimiter":",","format":"%u%n","precision":2,"separator":".","unit":"$"}}}});
EOS
)
      fr_output = File.read(File.join(I18n::JS.export_i18n_js_dir_path, "bits.fr.js"))
      expect(fr_output).to eq(<<EOS
I18n.translations || (I18n.translations = {});
I18n.translations["fr"] = I18n.extend((I18n.translations["fr"] || {}), {"date":{"formats":{"default":"%d/%m/%Y","long":"%e %B %Y","long_ordinal":"%e %B %Y","only_day":"%e","short":"%e %b"}},"number":{"currency":{"format":{"format":"%n %u","precision":2,"unit":"€"}}}});
EOS
)
    end

    it "exports as json only" do
      set_config "json_only.yml"
      I18n::JS.export
      en_output = File.read(File.join(I18n::JS.export_i18n_js_dir_path, "json_only.en.js"))
      fr_output = File.read(File.join(I18n::JS.export_i18n_js_dir_path, "json_only.fr.js"))
      expect(en_output).to eq (<<EOS
{"en":{"date":{"formats":{"default":"%Y-%m-%d","long":"%B %d, %Y","short":"%b %d"}},"number":{"currency":{"format":{"delimiter":",","format":"%u%n","precision":2,"separator":".","unit":"$"}}}}}
EOS
).chop
      expect(fr_output).to eq (<<EOS
{"fr":{"date":{"formats":{"default":"%d/%m/%Y","long":"%e %B %Y","long_ordinal":"%e %B %Y","only_day":"%e","short":"%e %b"}},"number":{"currency":{"format":{"format":"%n %u","precision":2,"unit":"€"}}}}}
EOS
).chop
      expect(JSON.parse(en_output).keys.first).to eq 'en'
    end

    it "exports with :except condition" do
      set_config "except_condition.yml"
      I18n::JS.export

      file_should_exist "trimmed.js"
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

    describe ".filtered_translations" do
      subject do
        I18n::JS.filtered_translations
      end

      let!(:old_sort_translation_keys) { I18n::JS.sort_translation_keys? }
      before { I18n::JS.sort_translation_keys = sort_translation_keys_value }
      after { I18n::JS.sort_translation_keys = old_sort_translation_keys }
      before { expect(I18n::JS.sort_translation_keys?).to eq(sort_translation_keys_value) }

      let(:sorted_hash) do
        {sorted: :hash}
      end
      before do
        allow(I18n::JS::Utils).
          to receive(:deep_key_sort).
          and_return(sorted_hash)
      end

      shared_examples_for ".filtered_translations" do
        subject do
          I18n::JS.filtered_translations
        end

        # This example is to prevent the regression from
        # PR https://github.com/fnando/i18n-js/pull/318
        it {should be_a(Hash)}
        # Might need to test the keys... or not
      end

      context "when translation keys SHOULD be sorted" do
        let(:sort_translation_keys_value) { true }

        it_behaves_like ".filtered_translations"
        it {should eq(sorted_hash)}
      end
      context "when translation keys should NOT be sorted" do
        let(:sort_translation_keys_value) { false }

        it_behaves_like ".filtered_translations"
        it {should_not eq(sorted_hash)}
      end
    end
  end

  context "exceptions" do
    it "does not include scopes listed in the exceptions list" do
      result = I18n::JS.scoped_translations("*", ['de.*', '*.admin', '*.*.currency'])

      expect(result[:de]).to be_empty

      expect(result[:en][:admin]).to be_nil
      expect(result[:fr][:admin]).to be_nil
      expect(result[:ja][:admin]).to be_nil

      expect(result[:en][:number][:currency]).to be_nil
      expect(result[:fr][:number][:currency]).to be_nil
    end

    it "does not include scopes listed in the exceptions list and respects the 'only' option" do
      result = I18n::JS.scoped_translations("fr.*", ['*.admin', '*.*.currency'])

      expect(result[:en]).to be_nil
      expect(result[:de]).to be_nil
      expect(result[:ja]).to be_nil

      expect(result[:fr][:admin]).to be_nil
      expect(result[:fr][:number][:currency]).to be_nil

      expect(result[:fr][:time][:am]).to be_a(String)
    end

    it "does exclude absolute scopes listed in the exceptions list" do
      result = I18n::JS.scoped_translations("*", ['de', 'en.admin', 'fr.number.currency'])

      expect(result[:de]).to be_nil

      expect(result[:en]).to be_a(Hash)
      expect(result[:en][:admin]).to be_nil

      expect(result[:fr][:number]).to be_a(Hash)
      expect(result[:fr][:number][:currency]).to be_nil
    end

    it "does not exclude non-absolute scopes listed in the exceptions list" do
      result = I18n::JS.scoped_translations("*", ['admin', 'currency'])

      expect(result[:en][:admin]).to be_a(Hash)
      expect(result[:fr][:admin]).to be_a(Hash)
      expect(result[:ja][:admin]).to be_a(Hash)

      expect(result[:en][:number][:currency]).to be_a(Hash)
      expect(result[:fr][:number][:currency]).to be_a(Hash)
    end
  end

  context "fallbacks" do
    subject(:translations) do
      I18n::JS.translation_segments.first.translations
    end

    it "exports without fallback when disabled" do
      set_config "js_file_per_locale_without_fallbacks.yml"
      expect(subject[:fr][:fallback_test]).to eql(nil)
      expect(subject[:fr][:null_test]).to eql(nil)
      expect(subject[:de][:null_test]).to eql(nil)
    end

    it "exports with default_locale as fallback when enabled" do
      set_config "js_file_per_locale_with_fallbacks_enabled.yml"
      expect(subject[:fr][:fallback_test]).to eql("Success")
      expect(subject[:fr][:null_test]).to eql("fallback for null")
      expect(subject[:de][:null_test]).to eql("fallback for null")
    end

    it "exports with default_locale as fallback when enabled with :default_locale" do
      set_config "js_file_per_locale_with_fallbacks_as_default_locale_symbol.yml"
      expect(subject[:fr][:fallback_test]).to eql("Success")
      expect(subject[:fr][:null_test]).to eql("fallback for null")
      expect(subject[:de][:null_test]).to eql("fallback for null")
    end

    it "exports with given locale as fallback" do
      set_config "js_file_per_locale_with_fallbacks_as_locale.yml"
      expect(subject[:fr][:fallback_test]).to eql("Erfolg")
      expect(subject[:fr][:null_test]).to eql(nil)
      expect(subject[:de][:null_test]).to eql(nil)
    end

    context "when given locale is in `I18n.available_locales` but its translation is missing" do
      subject { translations[:fr][:fallback_test] }

      let(:new_locale) { :pirate }
      let!(:old_available_locales) { I18n.config.available_locales }
      let!(:new_available_locales) { I18n.config.available_locales + [new_locale] }
      before do
        I18n.config.available_locales = new_available_locales
        set_config "js_file_per_locale_with_fallbacks_as_locale_without_fallback_translations.yml"
      end
      after do
        I18n.config.available_locales = old_available_locales
      end

      it {should eql(nil)}
    end

    context "with I18n::Fallbacks enabled" do
      let(:backend_with_fallbacks) { backend_class_with_fallbacks.new }
      let!(:old_backebad) { I18n.backend }

      before do
        I18n::JS.backend = backend_with_fallbacks
        I18n.fallbacks[:fr] = [:de, :en]
      end
      after { I18n::JS.backend = old_backebad }

      it "exports with defined locale as fallback when enabled" do
        set_config "js_file_per_locale_with_fallbacks_enabled.yml"
        expect(subject[:fr][:fallback_test]).to eql("Erfolg")
      end

      it "exports with defined locale as fallback when enabled with :default_locale" do
        set_config "js_file_per_locale_with_fallbacks_as_default_locale_symbol.yml"
        expect(subject[:fr][:fallback_test]).to eql("Success")
      end

      it "exports with Fallbacks as Hash" do
        set_config "js_file_per_locale_with_fallbacks_as_hash.yml"
        expect(subject[:fr][:fallback_test]).to eql("Erfolg")
      end
    end
  end

  context "namespace and pretty_print options" do

    before do
      stub_const('I18n::JS::DEFAULT_EXPORT_DIR_PATH', temp_path)
      set_config "js_file_with_namespace_and_pretty_print.yml"
    end

    it "exports with defined locale as fallback when enabled" do
      I18n::JS.export
      file_should_exist "en.js"
      output = File.read(File.join(I18n::JS.export_i18n_js_dir_path, "en.js"))
      expect(output).to match(/^#{
<<EOS
Foo.translations || (Foo.translations = {});
Foo.translations["en"] = {
  "number": {
      "format": {
EOS
}.+#{
<<EOS
    "edit": {
      "title": "Edit"
    }
  },
  "foo": "Foo",
  "fallback_test": "Success"
};
EOS
}$/)
    end
  end

  context "I18n.available_locales" do

    context "when I18n.available_locales is not set" do
      it "should allow all locales" do
        result = I18n::JS.scoped_translations("*.admin.*.title")

        expect(result[:en][:admin][:show][:title]).to eql("Show")
        expect(result[:fr][:admin][:show][:title]).to eql("Visualiser")
        expect(result[:ja][:admin][:show][:title]).to eql("Ignore me")
      end
    end

    context "when I18n.available_locales is set" do
      before { allow(::I18n).to receive(:available_locales){ [:en, :fr] } }

      it "should ignore non-valid locales" do
        result = I18n::JS.scoped_translations("*.admin.*.title")

        expect(result[:en][:admin][:show][:title]).to eql("Show")
        expect(result[:fr][:admin][:show][:title]).to eql("Visualiser")
        expect(result.keys.include?(:ja)).to eql(false)
      end
    end
  end

  context "general" do
    it "sets export directory" do
      expect(I18n::JS::DEFAULT_EXPORT_DIR_PATH).to eql("public/javascripts")
    end

    it "sets empty hash as configuration when no file is found" do
      expect(I18n::JS.config_file_exists?).to eql(false)
      expect(I18n::JS.config).to eql({})
    end

    it "executes erb in config file" do
      set_config "erb.yml"

      config_entry = I18n::JS.config[:translations].first
      expect(config_entry["only"]).to eq("*.date.formats")
    end
  end

  describe "i18n.js exporting" do
    after { begin described_class.send(:remove_instance_variable, :@export_i18n_js_dir_path); rescue; end }

    describe ".export_i18n_js with global variable" do
      before do
        allow(FileUtils).to receive(:mkdir_p).and_call_original
        allow(FileUtils).to receive(:cp).and_call_original

        allow(described_class).to receive(:export_i18n_js_dir_path).and_return(export_i18n_js_dir_path)
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
          expect(File).to be_file(File.join(I18n::JS.export_i18n_js_dir_path, "i18n.js"))
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

    describe ".export_i18n_js with config" do

      let(:export_action) do
        allow(FileUtils).to receive(:mkdir_p).and_call_original
        allow(FileUtils).to receive(:cp).and_call_original
        I18n::JS.export_i18n_js
      end

      context 'when :export_i18n_js set in config' do
        before { set_config "js_export_dir_custom.yml"; export_action }
        let(:export_i18n_js_dir_path) { temp_path }
        let(:config_export_path) { "tmp/i18n-js/foo" }

        it "does create the folder before copying" do
          expect(FileUtils).to have_received(:mkdir_p).with(config_export_path).once
        end
        it "does copy the file with FileUtils.cp" do
          expect(FileUtils).to have_received(:cp).once
        end
        it "exports the file" do
          expect(File).to be_file(File.join(config_export_path, "i18n.js"))
        end
      end

      context 'when .export_i18n_js_dir_path is set to false' do
        before { set_config "js_export_dir_none.yml"; export_action }

        it "does NOT create the folder before copying" do
          expect(FileUtils).to_not have_received(:mkdir_p)
        end

        it "does NOT copy the file with FileUtils.cp" do
          expect(FileUtils).to_not have_received(:cp)
        end
      end
    end

    describe '.export_i18n_js_dir_path' do
      let(:default_path) { I18n::JS::DEFAULT_EXPORT_DIR_PATH }
      let(:new_path) { File.join("tmp", default_path) }
      after { described_class.send(:remove_instance_variable, :@export_i18n_js_dir_path) }

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

        it { should eq :none }
      end
    end
  end

  describe "translation key sorting" do

    describe ".sort_translation_keys?" do
      after { described_class.send(:remove_instance_variable, :@sort_translation_keys) }
      subject { described_class.sort_translation_keys? }


      context "set with config" do

        context 'when :sort_translation_keys is not set in config' do
          before :each do
            set_config "default.yml"
          end

          it { should eq true }
        end

        context 'when :sort_translation_keys set to true in config' do
          before :each do
            set_config "js_sort_translation_keys_true.yml"
          end

          it { should eq true }
        end

        context 'when :sort_translation_keys set to false in config' do
          before :each do
            set_config "js_sort_translation_keys_false.yml"
          end

          it { should eq false }
        end
      end

      context 'set by .sort_translation_keys' do

        context "when it is not set" do
          it { should eq true }
        end

        context "when it is set to true" do
          before { described_class.sort_translation_keys = true }

          it { should eq true }
        end

        context "when it is set to false" do
          before { described_class.sort_translation_keys = false }

          it { should eq false }
        end
      end
    end

    context "exporting" do
      subject do
        I18n::JS.export
        file_should_exist "en.js"
        File.read(File.join(I18n::JS.export_i18n_js_dir_path, "en.js"))
      end

      before do
        stub_const('I18n::JS::DEFAULT_EXPORT_DIR_PATH', temp_path)
      end

      context 'sort_translation_keys is true' do
        before :each do
          set_config "js_sort_translation_keys_true.yml"
        end

        it "exports with the keys sorted" do
          expect(subject).to eq <<EOS
I18n.translations || (I18n.translations = {});
I18n.translations["en"] = I18n.extend((I18n.translations["en"] || {}), {"admin":{"edit":{"title":"Edit"},"show":{"note":"more details","title":"Show"}},"date":{"abbr_day_names":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"abbr_month_names":[null,"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"day_names":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],"formats":{"default":"%Y-%m-%d","long":"%B %d, %Y","short":"%b %d"},"month_names":[null,"January","February","March","April","May","June","July","August","September","October","November","December"]},"fallback_test":"Success","foo":"Foo","merge_plurals":{"one":"Apple","other":"Apples"},"null_test":"fallback for null","number":{"currency":{"format":{"delimiter":",","format":"%u%n","precision":2,"separator":".","unit":"$"}},"format":{"delimiter":",","precision":3,"separator":"."}},"time":{"am":"am","formats":{"default":"%a, %d %b %Y %H:%M:%S %z","long":"%B %d, %Y %H:%M","short":"%d %b %H:%M"},"pm":"pm"}});
EOS
        end
      end
    end
  end

  describe "js_extend option" do
    before do
      stub_const('I18n::JS::DEFAULT_EXPORT_DIR_PATH', temp_path)
    end

    it "exports with js_extend option at parent level" do
      set_config "js_extend_parent.yml"
      I18n::JS.export

      file_should_exist "js_extend_parent.js"

      output = File.read(File.join(I18n::JS.export_i18n_js_dir_path, "js_extend_parent.js"))
      expect(output).to eq(<<EOS
I18n.translations || (I18n.translations = {});
I18n.translations[\"en\"] = {\"date\":{\"formats\":{\"default\":\"%Y-%m-%d\",\"long\":\"%B %d, %Y\",\"short\":\"%b %d\"}}};
I18n.translations[\"fr\"] = {\"date\":{\"formats\":{\"default\":\"%d/%m/%Y\",\"long\":\"%e %B %Y\",\"long_ordinal\":\"%e %B %Y\",\"only_day\":\"%e\",\"short\":\"%e %b\"}}};
EOS
)
    end

    it "exports with js_extend option at segment level" do
      set_config "js_extend_segment.yml"
      I18n::JS.export

      file_should_exist "js_extend_segment.js"

      output = File.read(File.join(I18n::JS.export_i18n_js_dir_path, "js_extend_segment.js"))
      expect(output).to eq(<<EOS
I18n.translations || (I18n.translations = {});
I18n.translations[\"en\"] = {\"date\":{\"formats\":{\"default\":\"%Y-%m-%d\",\"long\":\"%B %d, %Y\",\"short\":\"%b %d\"}}};
I18n.translations[\"fr\"] = {\"date\":{\"formats\":{\"default\":\"%d/%m/%Y\",\"long\":\"%e %B %Y\",\"long_ordinal\":\"%e %B %Y\",\"only_day\":\"%e\",\"short\":\"%e %b\"}}};
EOS
)
    end
  end

  describe "merging plural keys" do
    before do
      stub_const('I18n::JS::DEFAULT_EXPORT_DIR_PATH', temp_path)
    end

    subject do
      File.read(File.join(I18n::JS.export_i18n_js_dir_path, "merge_plurals.js"))
    end

    it "should correctly merge the plural keys" do
      set_config "merge_plurals.yml"
      I18n::JS.export
      file_should_exist "merge_plurals.js"

      expect(subject).to eq <<EOS
I18n.translations || (I18n.translations = {});
I18n.translations[\"en\"] = I18n.extend((I18n.translations[\"en\"] || {}), {\"merge_plurals\":{\"one\":\"Apple\",\"other\":\"Apples\"}});\nI18n.translations[\"fr\"] = I18n.extend((I18n.translations[\"fr\"] || {}), {\"merge_plurals\":{\"one\":\"Pomme\",\"other\":\"Pommes\",\"zero\":\"Pomme\"}});
EOS
    end
  end
end
