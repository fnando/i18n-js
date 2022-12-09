# frozen_string_literal: true

module I18nJS
  require "i18n-js/plugin"

  class EmbedFallbackTranslationsPlugin < I18nJS::Plugin
    CONFIG_KEY = :embed_fallback_translations

    # This method must set up the basic plugin configuration, like adding the
    # config's root key in case your plugin accepts configuration (defined via
    # the config file).
    #
    # If you don't add this key, the linter will prevent non-default keys from
    # being added to the configuration file.
    def self.setup
      I18nJS::Schema.root_keys << CONFIG_KEY
    end

    # In case your plugin accepts configuration, this is where you must validate
    # the configuration, making sure only valid keys and type is provided.
    # If the configuration contains invalid data, then you must raise an
    # exception using something like
    # `raise I18nJS::Schema::InvalidError, error_message`.
    def self.validate_schema(config:)
      return unless config.key?(CONFIG_KEY)

      plugin_config = config[CONFIG_KEY]
      valid_keys = %i[enabled]
      schema = I18nJS::Schema.new(config)

      schema.expect_required_keys(valid_keys, plugin_config)
      schema.reject_extraneous_keys(valid_keys, plugin_config)
      schema.expect_enabled_config(CONFIG_KEY, plugin_config[:enabled])
    end

    # This method is responsible for transforming the translations. The
    # translations you'll receive may be already be filtered by other plugins
    # and by the default filtering itself. If you need to access the original
    # translations, use `I18nJS.translations`.
    #
    # Make sure you always check whether your plugin is active before
    # transforming translations; otherwise, opting out transformation won't be
    # possible.
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
