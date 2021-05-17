require "i18n/js/formatters/base"

module I18n
  module JS
    module Formatters
      class JS < Base
        def format(translations)
          contents = header
          translations.each do |locale, translations_for_locale|
            contents << line(locale, format_json(translations_for_locale))
          end
          contents << (@suffix || '')
        end

        protected

        def header
          text = @prefix || ''
          text + %(#{@namespace}.translations || (#{@namespace}.translations = {});\n)
        end

        def line(locale, translations)
          json_stringified = @pretty_print ? %(`#{translations}`) : %('#{translations}')
          if @js_extend
            %(#{@namespace}.translations["#{locale}"] = I18n.extend((#{@namespace}.translations["#{locale}"] || {}), JSON.parse(#{json_stringified}));\n)
          else
            %(#{@namespace}.translations["#{locale}"] = JSON.parse(#{json_stringified});\n)
          end
        end
      end
    end
  end
end
