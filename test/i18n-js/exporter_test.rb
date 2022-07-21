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
    actual_files = I18nJS.call(config_file: "./test/config/everything.yml")

    assert_exported_files ["test/output/everything.json"], actual_files
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "export all translations (json config)" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files = I18nJS.call(config_file: "./test/config/everything.json")

    assert_exported_files ["test/output/everything.json"], actual_files
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "export all translations using config object" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files = I18nJS.call(
      config: {
        translations: [
          {
            file: "test/output/everything.json",
            patterns: ["*"]
          }
        ]
      }
    )

    assert_exported_files ["test/output/everything.json"], actual_files
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "export all translations using gettext backend" do
    I18n.backend = GettextBackend.new
    I18n.load_path << Dir["./test/fixtures/po/*.po"]
    actual_files = I18nJS.call(config_file: "./test/config/everything.yml")

    assert_exported_files ["test/output/everything.json"], actual_files
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "export specific paths" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files = I18nJS.call(config_file: "./test/config/specific.yml")

    assert_exported_files ["test/output/specific.json"], actual_files
    assert_json_file "test/fixtures/expected/specific.json",
                     "test/output/specific.json"
  end

  test "export multiple files" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files =
      I18nJS.call(config_file: "./test/config/multiple_files.yml")

    assert_exported_files ["test/output/es.json", "test/output/pt.json"],
                          actual_files
    assert_json_file "test/fixtures/expected/multiple_files/es.json",
                     "test/output/es.json"
    assert_json_file "test/fixtures/expected/multiple_files/pt.json",
                     "test/output/pt.json"
  end

  test "export multiple files using :locale" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files =
      I18nJS.call(config_file: "./test/config/locale_placeholder.yml")

    expected_files = [
      "test/output/en.json",
      "test/output/es.json",
      "test/output/pt.json"
    ]

    assert_exported_files expected_files,
                          actual_files
    assert_json_file "test/fixtures/expected/multiple_files/es.json",
                     "test/output/es.json"
    assert_json_file "test/fixtures/expected/multiple_files/pt.json",
                     "test/output/pt.json"
  end

  test "export multiple files using :locale as dirname" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files =
      I18nJS.call(config_file: "./test/config/locale_placeholder_dir.yml")

    expected_files = [
      "test/output/en/translations.json",
      "test/output/es/translations.json",
      "test/output/pt/translations.json"
    ]

    assert_exported_files expected_files,
                          actual_files
    assert_json_file "test/fixtures/expected/multiple_files/es.json",
                     "test/output/es/translations.json"
    assert_json_file "test/fixtures/expected/multiple_files/pt.json",
                     "test/output/pt/translations.json"
  end

  test "export files using :digest" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files = I18nJS.call(config_file: "./test/config/digest.yml")

    expected_files = [
      "test/output/en.677728247a2f2111271f43d6a9c07d1a.json",
      "test/output/es.d69fc73259977c7d14254b019ff85ec5.json",
      "test/output/pt.c7ff3b8cc02447b25a1375854ea718f5.json"
    ]

    assert_exported_files expected_files, actual_files
    assert_json_file "test/fixtures/expected/multiple_files/en.json",
                     "test/output/en.677728247a2f2111271f43d6a9c07d1a.json"

    assert_json_file "test/fixtures/expected/multiple_files/es.json",
                     "test/output/es.d69fc73259977c7d14254b019ff85ec5.json"

    assert_json_file "test/fixtures/expected/multiple_files/pt.json",
                     "test/output/pt.c7ff3b8cc02447b25a1375854ea718f5.json"
  end
end
