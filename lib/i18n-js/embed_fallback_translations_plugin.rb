# frozen_string_literal: true

module I18nJS
  require "i18n-js/plugin"

  class EmbedFallbackTranslationsPlugin < I18nJS::Plugin
    CONFIG_KEY = :embed_fallback_translations

    def self.setup
      I18nJS::Schema.root_keys << CONFIG_KEY
    end

    def self.validate_schema(config:)
      return unless config.key?(CONFIG_KEY)

      plugin_config = config[CONFIG_KEY]
      valid_keys = %i[enabled]
      schema = I18nJS::Schema.new(config)

      schema.expect_required_keys(valid_keys, plugin_config)
      schema.reject_extraneous_keys(valid_keys, plugin_config)
      schema.expect_enabled_config(CONFIG_KEY, plugin_config[:enabled])
    end

    def self.transform(translations:, config:)
      return translations unless config.dig(CONFIG_KEY, :enabled)

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
