require "spec_helper"
require "fileutils"
require "pathname"

RSpec.describe ::I18n::JS::Configuration::YamlFileLoader do
  describe "file path validation" do
    subject { create_instance_proc }

    let(:create_instance_proc) do
      -> { create_instance }
    end
    let(:create_instance) do
      described_class.new(file_path)
    end

    context "when file_path is invalid" do
      let(:file_path) { "invalid_file_path_!&@%@^!#^" }

      it "raises a custom error" do
        should raise_error(::I18n::JS::Configuration::YamlFileLoader::Errors::FileNotFound)
      end
    end

    context "when file_path points to a non-exsiting file" do
      let(:file_path) { temp_path("ghost_file") }

      it "raises a custom error" do
        should raise_error(::I18n::JS::Configuration::YamlFileLoader::Errors::FileNotFound)
      end
    end

    context "when file_path points to a folder" do
      let(:file_path) { temp_path("i_am_a_folder") }

      before do
        FileUtils.mkdir_p(file_path)
      end

      it "raises a custom error" do
        should raise_error(::I18n::JS::Configuration::YamlFileLoader::Errors::FileNotFound)
      end
    end

    context "when file_path points to a valid file" do
      context "in form of string" do
        let(:file_path) do
          temp_path("i_am_a_folder/i_am_a_file")
        end

        before do
          FileUtils.mkdir_p(temp_path("i_am_a_folder"))
          FileUtils.touch(file_path)
        end

        it "does not raise error" do
          should_not raise_error
        end
      end

      context "in form of Pathname" do
        let(:file_path) do
          temp_path(Pathname.new("i_am_a_folder/i_am_a_file"))
        end

        before do
          FileUtils.mkdir_p(temp_path("i_am_a_folder"))
          FileUtils.touch(file_path)
        end

        it "does not raise error" do
          should_not raise_error
        end
      end
    end
  end

  describe "configuration mappings" do
    subject do
      loader_instance.load
      actual_subject
    end

    let(:loader_instance) do
      described_class.new(
        yaml_file_path,
        configuration: configuration,
      )
    end

    let(:configuration) do
      ::I18n::JS::Configuration.new
    end

    let(:configuration_with_default_values) do
      ::I18n::JS::Configuration.new.freeze
    end

    let(:yaml_file_path) do
      temp_path("#{(0...10).map { ('a'..'z').to_a[rand(26)] }.join}.yaml")
    end

    before do
      FileUtils.mkdir_p(temp_path)
      File.open(yaml_file_path, "w") do |file|
        file.write(yaml_file_content)
      end
    end

    describe "fallbacks" do
      let(:actual_subject) do
        configuration.fallbacks
      end

      context "when key does not exist" do
        let(:yaml_file_content) do
          ""
        end

        it "returns the default value" do
          should eq(configuration_with_default_values.fallbacks)
        end
      end

      context "when value is false" do
        let(:yaml_file_content) do
          <<-YAML
          fallbacks: false
          YAML
        end

        it { should eq false }
      end

      context "when value is true" do
        let(:yaml_file_content) do
          <<-YAML
          fallbacks: true
          YAML
        end

        it { should eq true }
      end

      context "when value is a symbol" do
        let(:yaml_file_content) do
          <<-YAML
          fallbacks: :en
          YAML
        end

        it { should eq :en }
      end

      context "when value is a hash" do
        let(:yaml_file_content) do
          <<-YAML
          fallbacks:
            fr: ["de", "en"]
            de: "en"
          YAML
        end

        it { should eq({"fr" => ["de", "en"], "de" => "en"}) }
      end
    end

    describe "i18n_js_export_path" do
      let(:actual_subject) do
        configuration.i18n_js_export_path
      end

      context "when key does not exist" do
        let(:yaml_file_content) do
          ""
        end

        it "returns the default value" do
          should eq(configuration_with_default_values.i18n_js_export_path)
        end
      end

      context "when value is false" do
        let(:yaml_file_content) do
          <<-YAML
          i18n_js_export_path: false
          YAML
        end

        it { should eq nil }
      end

      context "when value is a string" do
        let(:yaml_file_content) do
          <<-YAML
          i18n_js_export_path: tmp/i18n.js
          YAML
        end

        it { should eq "tmp/i18n.js" }
      end
    end

    describe "sort_translation_keys" do
      let(:actual_subject) do
        configuration.sort_translation_keys?
      end

      context "when key does not exist" do
        let(:yaml_file_content) do
          ""
        end

        it "returns the default value" do
          should eq(configuration_with_default_values.sort_translation_keys?)
        end
      end

      context "when value is false" do
        let(:yaml_file_content) do
          <<-YAML
          sort_translation_keys: false
          YAML
        end

        it { should eq false }
      end

      context "when value is true" do
        let(:yaml_file_content) do
          <<-YAML
          sort_translation_keys: tmp/i18n.js
          YAML
        end

        it { should eq true }
      end
    end

    describe "translation_segment_settings" do
      let(:actual_subject) do
        configuration.translation_segment_settings.to_a
      end

      shared_context "when existing custom settings exists" do
        before do
          configuration.translation_segment_settings = existing_translation_segment_settings
        end

        let(:existing_translation_segment_settings) do
          [
            {
              file: "tmp/engine_translations.js",
              namespace: "Engine",
              pretty_print: false,
            }
          ]
        end
      end

      context "when key does not exist" do
        let(:yaml_file_content) do
          ""
        end

        it "returns the default value" do
          should eq(configuration_with_default_values.translation_segment_settings.to_a)
        end

        context "when existing custom settings exists" do
          include_context "when existing custom settings exists"

          it "returns the existing value" do
            should eq(existing_translation_segment_settings)
          end
        end
      end

      context "when value is empty" do
        let(:yaml_file_content) do
          <<-YAML
          translation_segment_settings: []
          YAML
        end

        it "returns the new value from YAML" do
          should eq []
        end

        context "when existing custom settings exists" do
          include_context "when existing custom settings exists"

          it "returns the new value from YAML" do
            should eq []
          end
        end
      end

      context "when value is an array" do
        let(:yaml_file_content) do
          <<-YAML
          translation_segment_settings:
          - file: "tmp/translations.js"
            only: ["*.abc.*"]
            except: ["*.efg.*"]
            namespace: "MyNamespace"
            pretty_print: true
          YAML
        end
        
        let(:new_translation_segment_settings) do
          [
            {
              file: "tmp/translations.js",
              only: ["*.abc.*"],
              except: ["*.efg.*"],
              namespace: "MyNamespace",
              pretty_print: true,
            }
          ]
        end

        it "returns the new value from YAML" do
          should eq(new_translation_segment_settings)
        end

        context "when existing custom settings exists" do
          include_context "when existing custom settings exists"

          it "returns the new value from YAML" do
            should eq(new_translation_segment_settings)
          end
        end
      end
    end
  end

  describe "default loading without `configuration` option" do
    subject do
      loader_instance.load
      configuration
    end

    let(:loader_instance) do
      described_class.new(
        file_path,
      )
    end

    let(:configuration) do
      ::I18n::JS.configuration
    end
  end
end
