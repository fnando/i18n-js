module I18n
  module JS

    # Class which enscapulates a translations hash and outputs a single JSON translation file
    class Segment
      attr_accessor :file, :translations

      def initialize(file, translations, options = {})
        @file         = file
        @translations = translations
      end

      # Saves JSON file containing translations
      def save!
        FileUtils.mkdir_p File.dirname(self.file)

        File.open(self.file, "w+") do |f|
          f << %(I18n.translations || (I18n.translations = {});\n)
          self.translations.each do |locale, translations|
            f << %(I18n.translations["#{locale}"] = #{print_json(translations)};\n);
          end
        end
      end

      protected

      # Outputs pretty or ugly JSON depending on :pretty_print option
      def print_json(translations)
        translations.to_json
      end
    end
  end
end
