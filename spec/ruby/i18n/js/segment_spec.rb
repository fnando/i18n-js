require "spec_helper"

describe I18n::JS::Segment do

  let(:file)                  { "tmp/i18n-js/segment.js" }
  let(:translations)          { { en: { "test" => "Test" }, fr: { "test" => "Test2" } } }
  let(:namespace)             { "MyNamespace" }
  let(:pretty_print)          { nil }
  let(:js_extend)             { nil }
  let(:sort_translation_keys) { nil }
  let(:available_locales)     { %w(en fr de it) }

  let(:options) do
    {
      namespace: namespace,
      pretty_print: pretty_print,
      js_extend: js_extend,
      sort_translation_keys: sort_translation_keys,
      available_locales: available_locales
    }.delete_if { |_k, v| v.nil? }
  end

  subject { I18n::JS::Segment.new(file, translations, options) }

  describe ".new" do

    it "should persist the file path variable" do
      subject.file.should eql("tmp/i18n-js/segment.js")
    end

    it "should persist the translations variable" do
      subject.translations.should eql(translations)
    end

    it "should persist the namespace variable" do
      subject.namespace.should eql("MyNamespace")
    end

    it "should persist the available locales variable" do
      subject.available_locales.should eql(%w(en fr de it))
    end

    context "when namespace is nil" do
      let(:namespace){ nil }

      it "should default namespace to `I18n`" do
        subject.namespace.should eql("I18n")
      end
    end

    context "when namespace is not set" do
      subject { I18n::JS::Segment.new(file, translations) }

      it "should default namespace to `I18n`" do
        subject.namespace.should eql("I18n")
      end
    end

    context "when pretty_print is nil" do
      it "should set pretty_print to false" do
        subject.pretty_print.should be false
      end
    end

    context "when pretty_print is truthy" do
      let(:pretty_print){ 1 }

      it "should set pretty_print to true" do
        subject.pretty_print.should be true
      end
    end

    context "when available_locales is not set" do
      let(:available_locales) { nil }

      it "should set available_locales to I18n.available_locales" do
        subject.available_locales.should eql(I18n.available_locales)
      end

      context "when I18n does not have a available_locales method" do
        before { allow(I18n).to receive(:available_locales).and_raise(NoMethodError) }

        it "should set available_locales to an empty array" do
          subject.available_locales.should eql([])
        end
      end
    end
  end

  describe "#save!" do
    before { allow(I18n::JS).to receive(:export_i18n_js_dir_path).and_return(temp_path) }
    before { subject.save! }

    let(:available_locales) { nil } # Fall back to I18n.available_locales

    context "when file does not include %{locale}" do
      it "should write the file" do
        file_should_exist "segment.js"

        File.open(File.join(temp_path, "segment.js")){|f| f.read}.should eql <<-EOF
MyNamespace.translations || (MyNamespace.translations = {});
MyNamespace.translations["en"] = I18n.extend((MyNamespace.translations["en"] || {}), {"test":"Test"});
MyNamespace.translations["fr"] = I18n.extend((MyNamespace.translations["fr"] || {}), {"test":"Test2"});
        EOF
      end
    end

    context "when file includes %{locale}" do
      let(:file){ "tmp/i18n-js/%{locale}.js" }

      it "should write files" do
        file_should_exist "en.js"
        file_should_exist "fr.js"

        File.open(File.join(temp_path, "en.js")){|f| f.read}.should eql <<-EOF
MyNamespace.translations || (MyNamespace.translations = {});
MyNamespace.translations["en"] = I18n.extend((MyNamespace.translations["en"] || {}), {"test":"Test"});
        EOF

        File.open(File.join(temp_path, "fr.js")){|f| f.read}.should eql <<-EOF
MyNamespace.translations || (MyNamespace.translations = {});
MyNamespace.translations["fr"] = I18n.extend((MyNamespace.translations["fr"] || {}), {"test":"Test2"});
        EOF
      end
    end

    context "when js_extend is true" do
      let(:js_extend){ true }

      let(:translations){ { en: { "b" => "Test", "a" => "Test" } } }

      it 'should output the keys as sorted' do
        file_should_exist "segment.js"

        File.open(File.join(temp_path, "segment.js")){|f| f.read}.should eql <<-EOF
MyNamespace.translations || (MyNamespace.translations = {});
MyNamespace.translations["en"] = I18n.extend((MyNamespace.translations["en"] || {}), {"a":"Test","b":"Test"});
        EOF
      end
    end

    context "when js_extend is false" do
      let(:js_extend){ false }

      let(:translations){ { en: { "b" => "Test", "a" => "Test" } } }

      it 'should output the keys as sorted' do
        file_should_exist "segment.js"

        File.open(File.join(temp_path, "segment.js")){|f| f.read}.should eql <<-EOF
MyNamespace.translations || (MyNamespace.translations = {});
MyNamespace.translations["en"] = {"a":"Test","b":"Test"};
        EOF
      end
    end

    context "when sort_translation_keys is true" do
      let(:sort_translation_keys){ true }

      let(:translations){ { en: { "b" => "Test", "a" => "Test" } } }

      it 'should output the keys as sorted' do
        file_should_exist "segment.js"

        File.open(File.join(temp_path, "segment.js")){|f| f.read}.should eql <<-EOF
MyNamespace.translations || (MyNamespace.translations = {});
MyNamespace.translations["en"] = I18n.extend((MyNamespace.translations["en"] || {}), {"a":"Test","b":"Test"});
        EOF
      end
    end

    context "when sort_translation_keys is false" do
      let(:sort_translation_keys){ false }

      let(:translations){ { en: { "b" => "Test", "a" => "Test" } } }

      it 'should output the keys as sorted' do
        file_should_exist "segment.js"

        File.open(File.join(temp_path, "segment.js")){|f| f.read}.should eql <<-EOF
MyNamespace.translations || (MyNamespace.translations = {});
MyNamespace.translations["en"] = I18n.extend((MyNamespace.translations["en"] || {}), {"b":"Test","a":"Test"});
        EOF
      end
    end
  end
end
