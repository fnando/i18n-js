module I18n
  module JS
    class Configuration
      DEFAULT_EXPORT_DIR_PATH = "public/javascripts"

      def initialize
        reset!
      end

      # Mainly used in testing
      def reset!
        @fallbacks                = true
        @sort_translation_keys    = true
        @i18n_js_export_path  = DEFAULT_EXPORT_DIR_PATH
        @translation_segment_settings = TranslationSegmentSettings.new([
          {
            file: "#{DEFAULT_EXPORT_DIR_PATH}/translations.js",
            only: "*",
          },
        ])
      end

      attr_accessor(*[
        :fallbacks,
      ])

      attr_reader(*[
        :i18n_js_export_path,
        :translation_segment_settings,
      ])

      def translation_segment_settings=(new_settings)
        @translation_segment_settings = TranslationSegmentSettings.new(new_settings)
      end

      # Custom accessors
      def export_i18n_js?
        i18n_js_export_path.is_a?(String)
      end

      ## Setting this to nil would disable i18n.js exporting
      def i18n_js_export_path=(new_path)
        new_path = nil unless new_path.is_a?(String)
        @i18n_js_export_path = new_path
      end

      def sort_translation_keys?
        @sort_translation_keys
      end

      def sort_translation_keys=(value)
        @sort_translation_keys = !!value
      end

      def use_fallbacks?
        !!fallbacks
      end

      class TranslationSegmentSettings
        def initialize(array_of_options)
          self.array_of_options = array_of_options
        end

        def to_a
          array_of_options.dup
        end

        protected

        def array_of_options=(new_array_of_options)
          @array_of_options = new_array_of_options.map do |options|
            convert_options(options)
          end
        end

        private

        attr_reader :array_of_options

        def convert_options(options)
          raise TypeError unless options.is_a?(Hash)

          Private::HashWithSymbolKeys.new(options)
        end
      end
    end
  end
end
