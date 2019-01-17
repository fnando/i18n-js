module I18n
  module JS
    class JsonOnlyLocaleRequiredError < StandardError
      def message
        'The json_only option requires %{locale} in the file name.'
      end
    end
  end
end
