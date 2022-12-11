# frozen_string_literal: true

require "test_helper"

class SchemaTest < Minitest::Test
  test "accepts valid root keys" do
    I18nJS::Schema.validate!(
      translations: [
        {
          file: "app/frontend/locales/en.json",
          patterns: [
            "*"
          ]
        }
      ]
    )
  end

  test "requires config to be a hash" do
    assert_schema_error("Expected :root to be Hash; got NilClass instead") do
      I18nJS::Schema.validate!(nil)
    end
  end

  test "requires translations key" do
    assert_schema_error("Expected :translations to be defined") do
      I18nJS::Schema.validate!({})
    end
  end

  test "rejects extraneous keys on root" do
    assert_schema_error("Unexpected keys: foo") do
      I18nJS::Schema.validate!(
        translations: [{file: "file.json", patterns: ["*"]}],
        foo: 1
      )
    end
  end

  test "requires translations key to be an array" do
    assert_schema_error(
      "Expected :translations to be Array; got Hash instead"
    ) do
      I18nJS::Schema.validate!(translations: {})
    end
  end

  test "requires at least one translation config" do
    assert_schema_error("Expected :translations to have at least one item") do
      I18nJS::Schema.validate!(
        translations: []
      )
    end
  end

  test "requires translation to have :file key defined" do
    assert_schema_error("Expected :file to be defined") do
      I18nJS::Schema.validate!(
        translations: [{patterns: "*"}]
      )
    end
  end

  test "requires translation's :file to be a string" do
    assert_schema_error("Expected :file to be String; got NilClass instead") do
      I18nJS::Schema.validate!(
        translations: [{file: nil, patterns: "*"}]
      )
    end
  end

  test "requires translation to have :patterns key defined" do
    assert_schema_error("Expected :patterns to be defined") do
      I18nJS::Schema.validate!(
        translations: [{file: "some/file.json"}]
      )
    end
  end

  test "requires extraneous keys on translation" do
    assert_schema_error("Unexpected keys: foo") do
      I18nJS::Schema.validate!(
        translations: [{foo: 1, file: "some/file.json", patterns: ["*"]}]
      )
    end
  end

  test "requires :patterns to be an array" do
    assert_schema_error(
      "Expected :patterns to be Array; got NilClass instead"
    ) do
      I18nJS::Schema.validate!(
        translations: [{patterns: nil, file: "some/file.json"}]
      )
    end
  end

  test "requires translation's :patterns to have at least one item" do
    assert_schema_error("Expected :patterns to have at least one item") do
      I18nJS::Schema.validate!(
        translations: [{file: "some/file.json", patterns: []}]
      )
    end
  end

  test "requires lint_translations' :ignore to be a hash" do
    error_message =
      "Expected :lint_translations to be Hash; got NilClass instead"

    assert_schema_error(error_message) do
      I18nJS::Schema.validate!(
        translations: [
          {
            file: "some/file.json",
            patterns: ["*"]
          }
        ],
        lint_translations: nil
      )
    end
  end

  test "requires lint_translations' :ignore to have :ignore" do
    assert_schema_error("Expected :ignore to be defined") do
      I18nJS::Schema.validate!(
        translations: [
          {
            file: "some/file.json",
            patterns: ["*"]
          }
        ],
        lint_translations: {}
      )
    end
  end

  test "requires lint_translations' :ignore to be an array" do
    assert_schema_error("Expected :ignore to be Array; got Hash instead") do
      I18nJS::Schema.validate!(
        translations: [
          {
            file: "some/file.json",
            patterns: ["*"]
          }
        ],
        lint_translations: {
          ignore: {}
        }
      )
    end
  end

  test "requires enabled type to be boolean" do
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
        enabled: nil
      }
    }

    plugin_class = Class.new(I18nJS::Plugin) do
      def setup
        I18nJS::Schema.root_keys << :sample
      end

      def validate_schema
        config_key = :sample
        plugin_config = config[config_key]
        schema = I18nJS::Schema.new(config)

        schema.expect_enabled_config(config_key, plugin_config[:enabled])
      end
    end

    I18nJS.register_plugin(plugin_class)
    I18nJS.initialize_plugins!(config: config)

    error_message =
      "Expected sample.enabled to be a boolean; got NilClass instead"

    assert_schema_error(error_message) do
      I18nJS::Schema.validate!(config)
    end
  end
end
