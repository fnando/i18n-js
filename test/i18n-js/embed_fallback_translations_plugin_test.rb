# frozen_string_literal: true

require "test_helper"

class EmbedFallbackTranslationsPluginTest < Minitest::Test
  let(:backend_class) do
    Class.new(I18n::Backend::Simple) do
      include I18n::Backend::Fallbacks
    end
  end

  test "embeds fallback translations" do
    require "i18n-js/embed_fallback_translations_plugin"
    I18nJS.register_plugin(I18nJS::EmbedFallbackTranslationsPlugin)

    I18n.load_path << Dir[
      "./test/fixtures/yml/*.yml",
      "./test/fixtures/embed/*.yml"
    ]
    actual_files =
      I18nJS.call(config_file: "./test/config/embed_fallback_translations.yml")

    assert_exported_files ["test/output/embed_fallback_translations.json"],
                          actual_files
    assert_json_file "test/fixtures/expected/embed_fallback_translations.json",
                     "test/output/embed_fallback_translations.json"
  end

  test "respects I18n.fallbacks chain when configured (using array)" do
    require "i18n/backend/fallbacks"
    require "i18n-js/embed_fallback_translations_plugin"
    I18nJS.register_plugin(I18nJS::EmbedFallbackTranslationsPlugin)

    I18n.backend = backend_class.new
    I18n.default_locale = :en
    I18n.fallbacks = %i[pt en]

    I18n.load_path << Dir[
      "./test/fixtures/yml/*.yml",
      "./test/fixtures/embed/*.yml"
    ]
    actual_files = I18nJS.call(
      config_file:
        "./test/config/embed_fallback_translations_with_i18n_fallbacks.yml"
    )

    assert_exported_files(
      ["test/output/embed_fallback_translations_with_i18n_fallbacks.json"],
      actual_files
    )
    assert_json_file(
      "test/fixtures/expected/" \
      "embed_fallback_translations_with_i18n_fallbacks.json",
      "test/output/embed_fallback_translations_with_i18n_fallbacks.json"
    )
  end

  test "respects I18n.fallbacks chain when configured (using instance)" do
    require "i18n/backend/fallbacks"
    require "i18n-js/embed_fallback_translations_plugin"
    I18nJS.register_plugin(I18nJS::EmbedFallbackTranslationsPlugin)

    backend_class = Class.new(I18n::Backend::Simple) do
      include I18n::Backend::Fallbacks
    end

    I18n.backend = backend_class.new

    I18n.default_locale = :en
    I18n.fallbacks = I18n::Locale::Fallbacks.new(I18n.default_locale, es: [:pt])

    I18n.load_path << Dir[
      "./test/fixtures/yml/*.yml",
      "./test/fixtures/embed/*.yml"
    ]
    actual_files = I18nJS.call(
      config_file:
        "./test/config/embed_fallback_translations_with_i18n_fallbacks.yml"
    )

    assert_exported_files(
      ["test/output/embed_fallback_translations_with_i18n_fallbacks.json"],
      actual_files
    )
    assert_json_file(
      "test/fixtures/expected/" \
      "embed_fallback_translations_with_i18n_fallbacks.json",
      "test/output/embed_fallback_translations_with_i18n_fallbacks.json"
    )
  end
end
