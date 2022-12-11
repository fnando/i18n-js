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

      class_eval(&block) if block
    end
  end

  test "implements default transform method" do
    plugin_class = create_plugin
    plugin = plugin_class.new(config: {})
    translations = {}

    assert_same translations,
                plugin.transform(translations: translations)
  end

  test "registers plugin" do
    plugin_class = create_plugin
    I18nJS.register_plugin(plugin_class)

    assert_includes I18nJS.available_plugins, plugin_class
  end

  test "setups plugin" do
    plugin_class = create_plugin do
      def setup
        I18nJS::Schema.root_keys << :sample
      end
    end

    I18nJS.register_plugin(plugin_class)
    I18nJS.initialize_plugins!(config: {})

    assert_includes I18nJS::Schema.root_keys, :sample
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
      ],
      sample: {
        enabled: true
      }
    }

    plugin_class = create_plugin do
      def setup
        I18nJS::Schema.root_keys << config_key
      end

      def validate_schema
        self.class.calls << :validated_schema
      end
    end

    I18nJS.register_plugin(plugin_class)
    I18nJS.initialize_plugins!(config: config)
    I18nJS::Schema.validate!(config)

    assert_equal 1, plugin_class.calls.size
    assert_includes plugin_class.calls, :validated_schema
  end

  test "runs after_export event" do
    config = Glob::SymbolizeKeys.call(
      I18nJS.load_config_file("./test/config/locale_placeholder.yml")
        .merge(sample: {enabled: true})
    )

    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    expected_files = [
      "test/output/en.json",
      "test/output/es.json",
      "test/output/pt.json"
    ]

    plugin_class = create_plugin do
      class << self
        attr_accessor :received_config, :received_files
      end

      def setup
        I18nJS::Schema.root_keys << :sample
      end

      def after_export(files:)
        self.class.received_files = files
      end
    end

    I18nJS.register_plugin(plugin_class)

    actual_files =
      I18nJS.call(config: config)

    assert_exported_files expected_files, actual_files
    assert_exported_files expected_files, plugin_class.received_files
  end

  test "loads plugins using rubygems" do
    Gem
      .expects(:find_files)
      .with("i18n-js/*_plugin.rb")
      .returns(["/path/to/i18n-js/fallback_plugin.rb"])

    I18nJS.expects(:require).with("/path/to/i18n-js/fallback_plugin.rb")

    I18nJS.load_plugins!
  end

  test "infers config key out of class name" do
    {
      "SamplePlugin" => :sample,
      "EmbedFallbackTranslationsPlugin" => :embed_fallback_translations,
      "ExportFilesPlugin" => :export_files,
      "FetchFromHTTPPlugin" => :fetch_from_http,
      "HTTPClientPlugin" => :http_client
    }.each do |class_name, key|
      plugin_class = Class.new(I18nJS::Plugin)
      plugin_class.stubs(:name).returns(class_name)
      plugin = plugin_class.new(config: {})

      assert_equal key, plugin.config_key
    end
  end
end
