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

      if use_fallback?
        transform_with_i18n_fallbacks(translations)
      else
        transform_with_default_locale(translations)
      end
    end

    private def use_fallback?
      I18n.backend.class.included_modules.include?(I18n::Backend::Fallbacks) &&
        I18n.respond_to?(:fallbacks) &&
        I18n.fallbacks.defaults.any?
    end

    private def transform_with_default_locale(translations)
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

    private def transform_with_i18n_fallbacks(translations)
      translations_with_fallback = {}

      translations.each do |locale, result|
        if locale == I18n.default_locale
          translations_with_fallback[locale] = result
          next
        end

        fallback_locales =
          I18n.fallbacks[locale].map(&:to_sym) - [locale.to_sym]

        fallback_locales.each do |fallback_locale|
          next unless translations[fallback_locale]

          result = I18nJS.deep_merge(translations[fallback_locale], result)
        end

        translations_with_fallback[locale] = result
      end

      translations_with_fallback
    end
  end

  I18nJS.register_plugin(EmbedFallbackTranslationsPlugin)
end
