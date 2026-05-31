# frozen_string_literal: true

require_relative "schema"

module I18nJS
  def self.available_plugins
    @available_plugins ||= Set.new
  end

  def self.register_plugin(plugin)
    available_plugins << plugin
  end

  def self.plugin_files
    Gem.find_files("i18n-js/*_plugin.rb")
  end

  def self.initialize_plugins!(config:)
    config.fetch(:pipeline, []).filter_map do |plugin_config|
      plugin_class = available_plugins.find do |klass|
        klass.key == plugin_config[:plugin]
      end

      plugin_config = plugin_config.except(:plugin)
      plugin = plugin_class.new(main_config: config, plugin_config:)

      next unless plugin.enabled?

      plugin.validate_schema
      plugin.setup
      plugin
    end
  end

  def self.load_plugins!
    plugin_files.each do |path|
      require path
    end
  end

  class Plugin
    # The plugin's configuration.
    attr_reader :config

    # The main configuration, which holds translation setup for
    # plugins that supports exporting.
    attr_reader :main_config

    # The schema validator for the plugin.
    attr_reader :schema

    # Infer the config key name out of the class.
    # If you plugin is called `MySamplePlugin`, the key will be `my_sample`.
    def self.key
      name.split("::").last
          .gsub(/Plugin$/, "")
          .gsub(/^([A-Z]+)([A-Z])/) { "#{$1.downcase}#{$2}" }
          .gsub(/^([A-Z]+)/) { $1.downcase }
          .gsub(/([A-Z]+)/m) { "_#{$1.downcase}" }
          .downcase
    end

    def initialize(plugin_config:, main_config:)
      @config = plugin_config
      @main_config = main_config
      @schema = Schema.new(config)
    end

    # Check whether plugin is enabled or not.
    # A plugin is enabled when the plugin configuration has `enabled: true`.
    def enabled?
      config[:enabled]
    end

    # This method is responsible for transforming the translations. The
    # translations you'll receive may be already be filtered by other plugins
    # and by the default filtering itself. If you need to access the original
    # translations, use `I18nJS.translations`.
    def transform(translations:)
      translations
    end

    # In case your plugin accepts configuration, this is where you must validate
    # the configuration, making sure only valid keys and type is provided.
    # If the configuration contains invalid data, then you must raise an
    # exception using something like
    # `raise I18nJS::Schema::InvalidError, error_message`.
    def validate_schema
    end

    # This method must set up the basic plugin configuration, like adding the
    # config's root key in case your plugin accepts configuration (defined via
    # the config file).
    #
    # If you don't add this key, the linter will prevent non-default keys from
    # being added to the configuration file.
    def setup
    end

    # This method is called whenever `I18nJS.call(**kwargs)` finishes exporting
    # JSON files based on your configuration.
    #
    # You can use it to further process exported files, or generate new files
    # based on the translations that have been exported.
    def after_export(files:)
    end
  end
end
