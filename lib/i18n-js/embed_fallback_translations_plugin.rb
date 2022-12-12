# frozen_string_literal: true

module I18nJS
  require "i18n-js/plugin"

  class EmbedFallbackTranslationsPlugin < I18nJS::Plugin
    def setup
      I18nJS::Schema.root_keys << config_key
    end

    def validate_schema
      valid_keys = %i[enabled]

      schema.expect_required_keys(keys: valid_keys, path: [config_key])
      schema.reject_extraneous_keys(keys: valid_keys, path: [config_key])
    end

    def transform(translations:)
      translations_glob = Glob.new(translations)
      translations_glob << "*"

      mapping = translations.keys.each_with_object({}) do |locale, buffer|
        buffer[locale] = Glob.new(translations[locale]).tap do |glob|
          glob << "*"
        end
      end

      default_locale = I18n.default_locale
      default_locale_glob = mapping.delete(default_locale)
      default_locale_paths = default_locale_glob.paths

      mapping.each do |locale, glob|
        missing_keys = default_locale_paths - glob.paths

        missing_keys.each do |key|
          components = key.split(".").map(&:to_sym)
          fallback_translation = translations.dig(default_locale, *components)

          next unless fallback_translation

          translations_glob.set([locale, key].join("."), fallback_translation)
        end
      end

      translations_glob.to_h
    end
  end

  I18nJS.register_plugin(EmbedFallbackTranslationsPlugin)
end
