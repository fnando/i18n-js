# frozen_string_literal: true

module I18nJS
  require "i18n-js/plugin"

  class EmbedFallbackTranslationsPlugin < I18nJS::Plugin
    def validate_schema
      valid_keys = %i[enabled]

      schema.expect_required_keys(keys: valid_keys)
      schema.reject_extraneous_keys(keys: valid_keys)
    end

    def transform(translations:)
      return translations unless enabled?

      fallback_locale = I18n.default_locale.to_sym
      locales_to_fallback = translations.keys - [fallback_locale]

      translations_with_fallback = {}
      translations_with_fallback[fallback_locale] =
        translations[fallback_locale]

      locales_to_fallback.each do |locale|
        translations_with_fallback[locale] = I18nJS.deep_merge(
          translations[fallback_locale], translations[locale]
        )
      end

      translations_with_fallback
    end
  end

  I18nJS.register_plugin(EmbedFallbackTranslationsPlugin)
end
