# frozen_string_literal: true

require_relative "schema"

module I18nJS
  def self.plugins
    @plugins ||= []
  end

  def self.register_plugin(plugin)
    plugins << plugin
    plugin.setup
  end

  def self.plugin_files
    Gem.find_files("i18n-js/*_plugin.rb")
  end

  def self.load_plugins!
    plugin_files.each do |path|
      require path
    end
  end

  class Plugin
    # This method must set up the basic plugin configuration, like adding the
    # config's root key in case your plugin accepts configuration (defined via
    # the config file).
    #
    # If you don't add this key, the linter will prevent non-default keys from
    # being added to the configuration file.
    def self.transform(translations:, config:) # rubocop:disable Lint/UnusedMethodArgument
      translations
    end

    # In case your plugin accepts configuration, this is where you must validate
    # the configuration, making sure only valid keys and type is provided.
    # If the configuration contains invalid data, then you must raise an
    # exception using something like
    # `raise I18nJS::Schema::InvalidError, error_message`.
    def self.validate_schema(config:)
    end

    # This method is responsible for transforming the translations. The
    # translations you'll receive may be already be filtered by other plugins
    # and by the default filtering itself. If you need to access the original
    # translations, use `I18nJS.translations`.
    #
    # Make sure you always check whether your plugin is active before
    # transforming translations; otherwise, opting out transformation won't be
    # possible.
    def self.setup
    end

    # This method is called whenever `I18nJS.call(**kwargs)` finishes exporting
    # JSON files based on your configuration.
    #
    # You can use it to further process exported files, or generate new files
    # based on the translations that have been exported.
    def self.after_export(files:)
    end
  end
end
