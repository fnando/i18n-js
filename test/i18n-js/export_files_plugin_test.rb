# frozen_string_literal: true

require "test_helper"

class ExportScriptFilesPluginTest < Minitest::Test
  test "exports script files" do
    require "i18n-js/export_files_plugin"
    I18nJS.plugins.clear
    I18nJS.register_plugin(I18nJS::ExportFilesPlugin)
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]

    now = Time.parse("2022-12-10T15:37:00")
    Time.stubs(:now).returns(now)

    exported_file =
      "test/output/export_files-3d4fd73158044f2545580d5fd9d09c77.ts"

    actual_files =
      I18nJS.call(config_file: "./test/config/export_files.yml")
    assert_exported_files ["test/output/export_files.json"], actual_files
    assert_file exported_file
    assert_equal File.read("test/fixtures/expected/export_files.ts"),
                 File.read(exported_file)
  end
end
