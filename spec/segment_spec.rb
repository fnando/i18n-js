require "spec_helper"

describe I18n::JS::Segment do

  let(:file)        { "tmp/i18n-js/segment.js" }
  let(:translations){ { "en" => { "test" => "Test" }, "fr" => { "test" => "Test2" } } }
  let(:namespace)   { "MyNamespace" }
  let(:pretty_print){ nil }
  let(:options)     { {namespace: namespace, pretty_print: pretty_print} }
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
  end

  describe "#save!" do
    before { allow(I18n::JS).to receive(:export_i18n_js_dir_path).and_return(temp_path) }
    before { subject.save! }

    it "should write the file" do
      file_should_exist "segment.js"

      File.open(File.join(temp_path, "segment.js")){|f| f.read}.should eql <<-EOF
MyNamespace.translations || (MyNamespace.translations = {});
MyNamespace.translations["en"] = {"test":"Test"};
MyNamespace.translations["fr"] = {"test":"Test2"};
EOF
    end
  end
end
