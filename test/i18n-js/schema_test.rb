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
end
