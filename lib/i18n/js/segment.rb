module I18n
  module JS

    # Class which enscapulates a translations hash and outputs a single JSON translation file
    class Segment
      attr_accessor :file, :translations, :namespace, :pretty_print

      LOCALE_INTERPOLATOR = /%\{locale\}/

      def initialize(file, translations, options = {})
        @file         = file
        @translations = translations
        @namespace    = options[:namespace] || 'I18n'
        @pretty_print = !!options[:pretty_print]
      end

      # Saves JSON file containing translations
      def save!
        if file =~ LOCALE_INTERPOLATOR
          I18n.available_locales.each do |locale|
            write_file(file_for_locale(locale), self.translations.slice(locale))
          end
        else
          write_file(self.file, self.translations)
        end
      end

      def write_file(_file, _translations)
        FileUtils.mkdir_p File.dirname(_file)
        File.open(_file, "w+") do |f|
          f << %(#{self.namespace}.translations || (#{self.namespace}.translations = {});\n)
          _translations.each do |locale, translations_for_locale|
            f << %(#{self.namespace}.translations["#{locale}"] = #{print_json(translations_for_locale)};\n);
          end
        end
      end

      protected

      # Outputs pretty or ugly JSON depending on :pretty_print option
      def print_json(translations)
        if pretty_print
          JSON.pretty_generate(translations)
        else
          translations.to_json
        end
      end

      # interpolates filename
      def file_for_locale(locale)
        self.file.gsub(LOCALE_INTERPOLATOR, locale.to_s)
      end
    end
  end
end
