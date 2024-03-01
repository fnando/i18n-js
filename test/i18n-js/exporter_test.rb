# frozen_string_literal: true

require "test_helper"

class ExporterTest < Minitest::Test
  test "fails when neither config_file nor config is set" do
    assert_raises(I18nJS::MissingConfigError) do
      I18nJS.call(config_file: nil, config: nil)
    end
  end

  test "exports all translations" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files = I18nJS.call(config_file: "./test/config/everything.yml")

    assert_exported_files ["test/output/everything.json"], actual_files
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "exports all translations (json config)" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files = I18nJS.call(config_file: "./test/config/everything.json")

    assert_exported_files ["test/output/everything.json"], actual_files
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "exports all translations using config object" do
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

  test "exports all translations using gettext backend" do
    I18n.backend = GettextBackend.new
    I18n.load_path << Dir["./test/fixtures/po/*.po"]
    actual_files = I18nJS.call(config_file: "./test/config/everything.yml")

    assert_exported_files ["test/output/everything.json"], actual_files
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "exports specific paths" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files = I18nJS.call(config_file: "./test/config/specific.yml")

    assert_exported_files ["test/output/specific.json"], actual_files
    assert_json_file "test/fixtures/expected/specific.json",
                     "test/output/specific.json"
  end

  test "exports multiple files" do
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

  test "exports multiple files using :locale" do
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

  test "exports multiple files using :locale as dirname" do
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

  test "exports files using :digest" do
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

  test "exports files using groups" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files = I18nJS.call(config_file: "./test/config/group.yml")

    expected_files = ["test/output/group.json"]

    assert_exported_files expected_files, actual_files
    assert_json_file "test/fixtures/expected/group.json",
                     "test/output/group.json"
  end

  test "exports files using erb" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files = I18nJS.call(config_file: "./test/config/config.yml.erb")

    expected_files = ["test/output/everything.json"]

    assert_exported_files expected_files, actual_files
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "exports files piping translation through plugins" do
    plugin_class = Class.new(I18nJS::Plugin) do
      def self.name
        "SamplePlugin"
      end

      def setup
        I18nJS::Schema.root_keys << config_key
      end

      def transform(translations:)
        translations.each_key do |locale|
          translations[locale][:injected] = "yes:#{locale}"
        end

        translations
      end
    end

    config = Glob::SymbolizeKeys.call(
      I18nJS.load_config_file("./test/config/everything.yml")
        .merge(sample: {enabled: true})
    )
    I18nJS.register_plugin(plugin_class)
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    I18nJS.call(config:)

    assert_json_file "test/fixtures/expected/transformed.json",
                     "test/output/everything.json"
  end

  test "does not overwrite exported files if identical" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    exported_file_path = "test/output/everything.json"

    # First run
    actual_files = I18nJS.call(config_file: "./test/config/everything.yml")

    assert_exported_files [exported_file_path], actual_files
    exported_file_mtime = File.mtime(exported_file_path)

    sleep 0.1

    # Second run
    I18nJS.call(config_file: "./test/config/everything.yml")

    # mtime should be the same
    assert_equal exported_file_mtime, File.mtime(exported_file_path)
  end

  test "overwrites exported files if not identical" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    exported_file_path = "test/output/everything.json"

    # First run
    actual_files = I18nJS.call(config_file: "./test/config/everything.yml")

    assert_exported_files [exported_file_path], actual_files

    # Change content of existed exported file (add space to the end of file).
    File.open(exported_file_path, "a") {|f| f << " " }
    exported_file_mtime = File.mtime(exported_file_path)

    sleep 0.1

    # Second run
    I18nJS.call(config_file: "./test/config/everything.yml")

    # File should overwritten to the correct one.
    assert_json_file "test/fixtures/expected/everything.json",
                     exported_file_path

    # mtime should be newer
    assert_operator File.mtime(exported_file_path), :>, exported_file_mtime
  end

  test "cleans hash when exporting files" do
    I18n.backend.store_translations(:en, {a: 1, b: {c: -> { }, d: 4}})

    actual_files = I18nJS.call(config_file: "./test/config/everything.yml")

    assert_exported_files ["test/output/everything.json"], actual_files
    assert_json_file "test/fixtures/expected/clean_hash.json",
                     "test/output/everything.json"
  end
end
