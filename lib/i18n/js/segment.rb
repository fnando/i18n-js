module I18n
  module JS

    # Class which enscapulates a translations hash and outputs a single JSON translation file
    class Segment
      OPTIONS = [:namespace, :pretty_print, :js_extend, :sort_translation_keys].freeze
      LOCALE_INTERPOLATOR = /%\{locale\}/

      attr_reader *([:file, :translations] | OPTIONS)

      def initialize(file, translations, options = {})
        @file         = file
        @translations = translations
        @namespace    = options[:namespace] || 'I18n'
        @pretty_print = !!options[:pretty_print]
        @js_extend    = options.key?(:js_extend) ? !!options[:js_extend] : true
        @sort_translation_keys = options.key?(:sort_translation_keys) ? !!options[:sort_translation_keys] : true
      end

      # Saves JSON file containing translations
      def save!
        if @file =~ LOCALE_INTERPOLATOR
          I18n.available_locales.each do |locale|
            write_file(file_for_locale(locale), @translations.slice(locale))
          end
        else
          write_file
        end
      end

      protected

      def write_file(_file = @file, _translations = @translations)
        FileUtils.mkdir_p File.dirname(_file)
        File.open(_file, "w+") do |f|
          f << js_header
          _translations.each do |locale, translations_for_locale|
            f << js_translations(locale, translations_for_locale)
          end
        end
      end

      def js_header
        %(#{@namespace}.translations || (#{@namespace}.translations = {});\n)
      end

      def js_translations(locale, translations)
        translations = Utils.deep_key_sort(translations) if @sort_translation_keys
        translations = print_json(translations)
        js_translations_line(locale, translations)
      end

      def js_translations_line(locale, translations)
        if @js_extend
          %(#{@namespace}.translations["#{locale}"] = I18n.extend((#{@namespace}.translations["#{locale}"] || {}), #{translations});\n)
        else
          %(#{@namespace}.translations["#{locale}"] = #{translations};\n)
        end
      end

      # Outputs pretty or ugly JSON depending on :pretty_print option
      def print_json(translations)
        if @pretty_print
          JSON.pretty_generate(translations)
        else
          translations.to_json
        end
      end

      # interpolates filename
      def file_for_locale(locale)
        @file.gsub(LOCALE_INTERPOLATOR, locale.to_s)
      end
    end
  end
end
