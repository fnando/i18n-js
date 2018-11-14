require "i18n/js/private/hash_with_symbol_keys"
require "i18n/js/errors"

module I18n
  module JS

    # Class which enscapulates a translations hash and outputs a single JSON translation file
    class Segment
      OPTIONS = [:namespace, :pretty_print, :js_extend, :sort_translation_keys, :json_only].freeze
      LOCALE_INTERPOLATOR = /%\{locale\}/

      attr_reader *([:file, :translations] | OPTIONS)

      def initialize(file, translations, options = {})
        @file         = file
        # `#slice` will be used
        # But when activesupport is absent,
        # the core extension from `i18n` gem will be used instead
        # And it's causing errors (at least in test)
        #
        # So the input is wrapped by our class for better `#slice`
        @translations = Private::HashWithSymbolKeys.new(translations)
        @namespace    = options[:namespace] || 'I18n'
        @pretty_print = !!options[:pretty_print]
        @js_extend    = options.key?(:js_extend) ? !!options[:js_extend] : true
        @sort_translation_keys = options.key?(:sort_translation_keys) ? !!options[:sort_translation_keys] : true
        @json_only = options.key?(:json_only) ? !!options[:json_only] : false
      end

      # Saves JSON file containing translations
      def save!
        if @file =~ LOCALE_INTERPOLATOR
          I18n.available_locales.each do |locale|
            write_file(file_for_locale(locale), @translations.slice(locale))
          end
        else
          if @json_only
            raise I18n::JS::JsonOnlyLocaleRequiredError
          end
          write_file
        end
      end

      protected

      def write_file(_file = @file, _translations = @translations)
        FileUtils.mkdir_p File.dirname(_file)
        contents = js_header
        _translations.each do |locale, translations_for_locale|
          contents << js_translations(locale, translations_for_locale)
        end

        return if File.exist?(_file) && File.read(_file) == contents

        File.open(_file, "w+") do |f|
          f << contents
        end
      end

      def js_header
        if @json_only
          ''
        else
          %(#{@namespace}.translations || (#{@namespace}.translations = {});\n)
        end
      end

      def js_translations(locale, translations)
        translations = Utils.deep_key_sort(translations) if @sort_translation_keys
        translations = print_json(translations)
        js_translations_line(locale, translations)
      end

      def js_translations_line(locale, translations)
        if @json_only
          %({"#{locale}":#{translations}})
        elsif @js_extend
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
