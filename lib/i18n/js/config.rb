module I18n
  module JS
    class Config
      def initialize(config)
        @config = config
      end

      def self.read(path)
        new(read_config(path))
      end

      def self.read_config(path)
        erb = ERB.new(File.read(path)).result
        (YAML.load(erb) || {}).with_indifferent_access
      end

      def translations
        @translations ||= map_translations
      end

      def map_translations
        @config.fetch(:translations, []).map do |options|
          options.reverse_merge(only: '*')
        end
      end

      def translations?
        translations.any?
      end

      def fallbacks
        @config.fetch(:fallbacks, true)
      end

      def use_fallbacks?
        fallbacks != false
      end
    end
  end
end
