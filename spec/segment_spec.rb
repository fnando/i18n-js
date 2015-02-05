require "spec_helper"

describe I18n::JS::Segment do

  let(:file)        { "tmp/i18n-js/segment.js" }
  let(:translations){ { "en" => { "test" => "Test" }, "fr" => { "test" => "Test2" } } }
  let(:options)     { {} }
  subject { I18n::JS::Segment.new(file, translations, options) }

  describe ".new" do

    it "should persist the file path variable" do
      subject.file.should eql("tmp/i18n-js/segment.js")
    end

    it "should persist the translations variable" do
      subject.translations.should eql(translations)
    end
  end

  describe "#save!" do
    before { allow(I18n::JS).to receive(:export_i18n_js_dir_path).and_return(temp_path) }
    before { subject.save! }

    it "should write the file" do
      file_should_exist "segment.js"

      File.open(File.join(temp_path, "segment.js")){|f| f.read}.should eql <<-EOF
I18n.translations || (I18n.translations = {});
I18n.translations["en"] = {"test":"Test"};
I18n.translations["fr"] = {"test":"Test2"};
EOF
    end
  end
end
