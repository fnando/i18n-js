# frozen_string_literal: true

require "test_helper"

class PluginTest < Minitest::Test
  def create_plugin(&block)
    Class.new(I18nJS::Plugin) do
      def self.name
        "SamplePlugin"
      end

      def self.calls
        @calls ||= []
      end

      instance_eval(&block) if block
    end
  end

  test "implements default transform method" do
    sample_plugin = create_plugin
    translations = {}

    assert_same translations,
                sample_plugin.transform(translations: translations, config: {})
  end

  test "registers plugin" do
    sample_plugin = create_plugin

    I18nJS.register_plugin(sample_plugin)

    assert_includes I18nJS.plugins, sample_plugin
  end

  test "setups plugin" do
    sample_plugin = create_plugin do
      def self.setup
        I18nJS::Schema.root_keys << :sample_plugin
      end
    end

    I18nJS.register_plugin(sample_plugin)

    assert_includes I18nJS::Schema.root_keys, :sample_plugin
  end

  test "validates schema" do
    config = {
      translations: [
        {
          file: "app/frontend/locales/en.json",
          patterns: [
            "*"
          ]
        }
      ]
    }

    sample_plugin = create_plugin do
      def self.validate_schema(config:)
        calls << config
      end
    end

    I18nJS.register_plugin(sample_plugin)
    I18nJS::Schema.validate!(config)

    assert_equal 1, sample_plugin.calls.size
    assert_includes sample_plugin.calls, config
  end

  test "runs after_export event" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    expected_files = [
      "test/output/en.json",
      "test/output/es.json",
      "test/output/pt.json"
    ]

    sample_plugin = create_plugin do
      def self.exported_files
        @exported_files ||= []
      end

      def self.after_export(files:)
        exported_files.push(*files)
      end
    end

    I18nJS.register_plugin(sample_plugin)

    actual_files =
      I18nJS.call(config_file: "./test/config/locale_placeholder.yml")

    assert_exported_files expected_files, actual_files
    assert_exported_files expected_files, sample_plugin.exported_files
  end

  test "loads plugins using rubygems" do
    Gem
      .expects(:find_files)
      .with("i18n-js/*_plugin.rb")
      .returns(["/path/to/i18n-js/fallback_plugin.rb"])

    I18nJS.expects(:require).with("/path/to/i18n-js/fallback_plugin.rb")

    I18nJS.load_plugins!
  end
end
