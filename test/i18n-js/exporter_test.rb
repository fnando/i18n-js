# frozen_string_literal: true

require "test_helper"

class ExporterTest < Minitest::Test
  test "fail when neither config_file nor config is set" do
    assert_raises(I18nJS::MissingConfigError) do
      I18nJS.call(config_file: nil, config: nil)
    end
  end

  test "export all translations" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    I18nJS.call(config_file: "./test/config/everything.yml")

    assert_file "test/output/everything.json"
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "export all translations (json config)" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    I18nJS.call(config_file: "./test/config/everything.json")

    assert_file "test/output/everything.json"
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "export all translations using config object" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    I18nJS.call(
      config: {
        translations: [
          {
            file: "test/output/everything.json",
            patterns: ["*"]
          }
        ]
      }
    )

    assert_file "test/output/everything.json"
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "export all translations using gettext backend" do
    I18n.backend = GettextBackend.new
    I18n.load_path << Dir["./test/fixtures/po/*.po"]
    I18nJS.call(config_file: "./test/config/everything.yml")

    assert_file "test/output/everything.json"
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "export specific paths" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    I18nJS.call(config_file: "./test/config/specific.yml")

    assert_file "test/output/specific.json"
    assert_json_file "test/fixtures/expected/specific.json",
                     "test/output/specific.json"
  end

  test "export multiple files" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    I18nJS.call(config_file: "./test/config/multiple_files.yml")

    assert_file "test/output/es.json"
    assert_file "test/output/pt.json"
    assert_json_file "test/fixtures/expected/multiple_files/es.json",
                     "test/output/es.json"
    assert_json_file "test/fixtures/expected/multiple_files/pt.json",
                     "test/output/pt.json"
  end

  test "export multiple files using :locale" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    I18nJS.call(config_file: "./test/config/locale_placeholder.yml")

    assert_file "test/output/es.json"
    assert_file "test/output/pt.json"
    assert_json_file "test/fixtures/expected/multiple_files/es.json",
                     "test/output/es.json"
    assert_json_file "test/fixtures/expected/multiple_files/pt.json",
                     "test/output/pt.json"
  end

  test "export multiple files using :locale as dirname" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    I18nJS.call(config_file: "./test/config/locale_placeholder_dir.yml")

    assert_file "test/output/es/translations.json"
    assert_file "test/output/pt/translations.json"
    assert_json_file "test/fixtures/expected/multiple_files/es.json",
                     "test/output/es/translations.json"
    assert_json_file "test/fixtures/expected/multiple_files/pt.json",
                     "test/output/pt/translations.json"
  end
end
