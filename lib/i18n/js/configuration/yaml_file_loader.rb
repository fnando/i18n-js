require "erb"
require "yaml"

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
          if config_from_file.key?(:export_i18n_js)
            configuration.export_i18n_js_dir_path = config_from_file.fetch(:export_i18n_js)
          end

          if config_from_file.key?(:sort_translation_keys)
            configuration.sort_translation_keys = config_from_file.fetch(:sort_translation_keys)
          end

          if config_from_file.key?(:fallbacks)
            configuration.fallbacks = config_from_file.fetch(:fallbacks)
          end

          if config_from_file.key?(:translations)
            configuration.translation_segment_settings = config_from_file.fetch(:translations)
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
            (::YAML.load(erb_result_from_yaml_file) || {}).tap do |hash|
              hash.extend HashWithIndifferentReadExtension
            end.freeze
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

        # Hash with indifferent access with partial implementation only
        # Assuming the keys are already strings,
        # since they are read from YAML files
        #
        # @api private
        module HashWithIndifferentReadExtension
          # If `#[]` cannot read value with symbol key, try string key
          def default(key = nil)
            if key.is_a?(Symbol) && key?(key = key.to_s)
              self[key]
            else
              super
            end
          end

          def fetch(key, *extras)
            super(convert_key(key), *extras)
          end

          def key?(key)
            super(convert_key(key))
          end

          alias_method :include?, :key?
          alias_method :has_key?, :key?
          alias_method :member?, :key?

          private

          def convert_key(key)
            key.is_a?(::Symbol) ? key.to_s : key
          end
        end
        private_constant :HashWithIndifferentReadExtension
      end
    end
  end
end
