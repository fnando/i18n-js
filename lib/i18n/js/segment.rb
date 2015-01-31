module I18n
  module JS

    # Class which enscapulates a translations hash and outputs a single JSON translation file
    class Segment
      attr_accessor :file, :translations, :namespace, :pretty_print

      def initialize(file, translations, options = {})
        @file         = file
        @translations = translations
        @namespace    = options[:namespace] || 'I18n'
        @pretty_print = !!options[:pretty_print]
      end

      # Saves JSON file containing translations
      def save!
        FileUtils.mkdir_p File.dirname(self.file)

        File.open(self.file, "w+") do |f|
          f << %(#{self.namespace}.translations || (#{self.namespace}.translations = {});\n)
          self.translations.each do |locale, translations|
            f << %(#{self.namespace}.translations["#{locale}"] = #{print_json(translations)};\n);
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
    end
  end
end
