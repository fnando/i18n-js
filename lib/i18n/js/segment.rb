module I18n
  module JS
    class Segment
      attr_accessor :file_path, :translations, :namespace

      def initialize(file_path, translations, namespace = nil)
        @file_path    = file_path
        @translations = translations
        @namespace    = namespace || 'I18n'
      end

      # Convert translations to JSON string and saves file
      def save!
        FileUtils.mkdir_p File.dirname(self.file_path)

        File.open(self.file_path, "w+") do |f|
          f << %(#{self.namespace}.translations || (#{self.namespace}.translations = {});\n)
          self.translations.each do |locale, translations_for_locale|
            f << %(#{self.namespace}.translations["#{locale}"] = #{translations_for_locale.to_json};\n);
          end
        end
      end
    end
  end
end
