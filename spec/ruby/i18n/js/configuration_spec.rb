require "spec_helper"

describe I18n::JS::Configuration do
  describe "constants" do
    it "has default export directory" do
      expect(described_class::DEFAULT_EXPORT_DIR_PATH).to eql("public/javascripts")
    end
  end

  describe "configurable attributes" do
    subject(:model) { described_class.new }

    describe "#fallback" do
      subject { model.fallbacks }

      let(:new_value) { :dummy_value_for_attribute }

      context "when it is not set" do
        it { should eq true }
      end

      context "when value is false" do
        before do
          model.fallbacks = true
        end

        it { should eq true }
      end

      context "when value is true" do
        before do
          model.fallbacks = true
        end

        it { should eq true }
      end

      context "when value is a symbol" do
        before do
          model.fallbacks = :en
        end

        it { should eq :en }
      end

      context "when value is a hash" do
        before do
          model.fallbacks = new_value
        end
        let(:new_value) do
          {
            fr: [:de, :en],
            de: :en,
          }
        end

        it { should eq(new_value) }
      end
    end


    describe "#export_i18n_js_dir_path" do
      subject { instance.export_i18n_js_dir_path }

      let(:instance) { described_class.new }

      let(:default_path) { described_class::DEFAULT_EXPORT_DIR_PATH }
      let(:new_path) { File.join("tmp", default_path) }

      context "when it is not set" do
        it { should eq default_path }
      end
      context "when it is set to another path already" do
        before { instance.export_i18n_js_dir_path = new_path }

        it { should eq new_path }
      end
      context "when it is set to nil already" do
        before { instance.export_i18n_js_dir_path = nil }

        it { should eq nil }
      end
    end

    describe ".sort_translation_keys?" do
      subject { instance.sort_translation_keys? }

      let(:instance) { described_class.new }

      after { instance.send(:remove_instance_variable, :@sort_translation_keys) }

      context 'set by #sort_translation_keys=' do
        context "when it is not set" do
          it { should eq true }
        end

        context "when it is set to true" do
          before { instance.sort_translation_keys = true }

          it { should eq true }
        end

        context "when it is set to false" do
          before { instance.sort_translation_keys = false }

          it { should eq false }
        end

        context "when it is set to nil" do
          before { instance.sort_translation_keys = nil }

          it { should eq false }
        end
      end
    end
  end
end
