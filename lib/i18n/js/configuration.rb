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
        @translation_segment_settings = [
          {
            file: "#{DEFAULT_EXPORT_DIR_PATH}/translations.js",
            only: "*",
          },
        ]
      end

      attr_accessor(*[
        :fallbacks,
        :translation_segment_settings,
        :i18n_js_export_path,
      ])

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
    end
  end
end
