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
    def self.transform(translations:, config:) # rubocop:disable Lint/UnusedMethodArgument
      translations
    end

    # Must raise I18nJS::SchemaInvalidError with the error message if schema
    # validation has failed.
    def self.validate_schema(config:)
    end

    def self.setup
    end
  end
end
