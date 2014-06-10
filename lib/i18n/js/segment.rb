module I18n
  module JS
    class Segment
      attr_accessor :file, :translations, :namespace

      def initialize(file, translations, namespace = nil)
        @file         = file
        @translations = translations
        @namespace    = namespace || 'I18n'
      end

      # Convert translations to JSON string and saves file
      def save!
        FileUtils.mkdir_p File.dirname(self.file)

        File.open(self.file, "w+") do |f|
          f << %(#{self.namespace}.translations || (#{self.namespace}.translations = {});\n)
          self.translations.each do |locale, translations_for_locale|
            f << %(#{self.namespace}.translations["#{locale}"] = #{translations_for_locale.to_json};\n);
          end
        end
      end
    end
  end
end
