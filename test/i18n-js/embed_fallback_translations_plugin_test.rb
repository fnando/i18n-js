# frozen_string_literal: true

require "test_helper"

class EmbedFallbackTranslationsPluginTest < Minitest::Test
  test "embeds fallback translations" do
    require "i18n-js/embed_fallback_translations_plugin"
    I18nJS.register_plugin(I18nJS::EmbedFallbackTranslationsPlugin)

    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
    actual_files =
      I18nJS.call(config_file: "./test/config/embed_fallback_translations.yml")

    assert_exported_files ["test/output/embed_fallback_translations.json"],
                          actual_files
    assert_json_file "test/fixtures/expected/embed_fallback_translations.json",
                     "test/output/embed_fallback_translations.json"
  end
end
