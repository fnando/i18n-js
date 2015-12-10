require "spec_helper"

describe I18n::JS::Segment do
  let(:file)        { "tmp/i18n-js/segment.js" }
  let(:translations){ { en: { "test" => "Test" }, fr: { "test" => "Test2" } } }
  let(:namespace)   { "MyNamespace" }
  let(:pretty_print){ nil }
  let(:options)     { {namespace: namespace, pretty_print: pretty_print} }
  subject(:instance) { I18n::JS::Segment.new(file, translations, options) }

  let!(:gem_config_setup) do
    # empty
  end

  describe ".new" do
    describe "attribute `file`" do
      subject { instance.file }

      it "does return value from argument" do
        should eql("tmp/i18n-js/segment.js")
      end
    end

    describe "attribute `translations`" do
      subject { instance.translations }

      it "does return value from argument" do
        should eql(translations)
      end
    end

    describe "option `namespace`" do
      subject { instance.namespace }

      it "does return value from options" do
        should eql(namespace)
      end

      context "when namespace is nil" do
        let(:namespace) { nil }

        it "does return `I18n`" do
          should eql("I18n")
        end
      end
    end

    describe "option `pretty_print`" do
      subject { instance.pretty_print }

      context "when pretty_print is nil" do
        let(:pretty_print) { nil }

        it "does return `false`" do
          should eql(false)
        end
      end

      context "when pretty_print is truthy" do
        let(:pretty_print) { 1 }

        it "does return value from options" do
          should eql(true)
        end
      end
    end


    describe "when options with string keys are used" do
      let(:options) do
        {
          "namespace".freeze    => namespace,
          "pretty_print".freeze => pretty_print,
        }
      end

      let(:namespace) { "MyNamespace" }
      let(:pretty_print) { 1 }

      describe "option `namespace`" do
        subject { instance.namespace }

        it "does return value from options" do
          should eql(namespace)
        end
      end

      describe "option `pretty_print`" do
        subject { instance.pretty_print }

        it "does return value from options" do
          should eql(true)
        end
      end
    end
  end

  describe "#save!" do
    before { subject.save! }

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

    context "when sort_translation_keys? is true" do
      let(:gem_config_setup) do
        I18n::JS.configuration.sort_translation_keys = true
      end

      let(:translations){ { en: { "b" => "Test", "a" => "Test" } } }

      it 'should output the keys as sorted' do
        file_should_exist "segment.js"

        File.open(File.join(temp_path, "segment.js")){|f| f.read}.should eql <<-EOF
MyNamespace.translations || (MyNamespace.translations = {});
MyNamespace.translations["en"] = I18n.extend((MyNamespace.translations["en"] || {}), {"a":"Test","b":"Test"});
        EOF
      end
    end
  end
end
