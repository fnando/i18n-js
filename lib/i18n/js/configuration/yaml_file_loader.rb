require "erb"
require "yaml"
require "i18n/js/private/hash_with_symbol_keys"

module I18n
  module JS
    class Configuration
      # Responsible for loading a YAML file and
      # putting the values into `Configuration` object
      class YamlFileLoader
        attr_reader :configuration, :yaml_file_path

        module Errors
          FileNotFound = Class.new(StandardError)
        end

        def initialize(yaml_file_path, options = {})
          @yaml_file_path = yaml_file_path
          @configuration  = options.fetch(:configuration) do
            # Default to the gem's config
            JS.configuration
          end

          validate_file_path!
        end

        # @raise [Errors::FileNotFound]
        #   When file does not exists
        def load
          if config_from_file.key?(:i18n_js_export_path)
            configuration.i18n_js_export_path = config_from_file.fetch(:i18n_js_export_path)
          end

          if config_from_file.key?(:sort_translation_keys)
            configuration.sort_translation_keys = config_from_file.fetch(:sort_translation_keys)
          end

          if config_from_file.key?(:fallbacks)
            configuration.fallbacks = config_from_file.fetch(:fallbacks)
          end

          if config_from_file.key?(:translation_segment_settings)
            configuration.translation_segment_settings = config_from_file.fetch(:translation_segment_settings)
          end
        end

        private

        def yaml_file
          @yaml_file ||= File.new(yaml_file_path)
        end

        # @return [Hash, #freeze?]
        #   It's frozen to ensure it's not modified by accident
        #   With non Active Support indifferent access
        def config_from_file
          @config_from_file ||= begin
            Private::HashWithSymbolKeys.new(
              (::YAML.load(erb_result_from_yaml_file) || {})
            ).freeze
          end
        end

        def erb_result_from_yaml_file
          ::ERB.new(yaml_file.read).result
        end

        def validate_file_path!
          unless ::File.file?(yaml_file_path)
            raise Errors::FileNotFound, "file with path #{yaml_file_path} is absent"
          end
        end
      end
    end
  end
end
