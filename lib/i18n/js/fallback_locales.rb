module I18n
  module JS
    class FallbackLocales
      attr_reader :fallbacks, :locale

      def initialize(fallbacks, locale)
        @fallbacks = fallbacks
        @locale = locale
      end

      def each
        locales.each { |locale| yield(locale) }
      end

      # Returns: An Array of locales to use as fallbacks for given locale.
      def locales
        locales = case fallbacks
                  when true
                    default_fallbacks
                  when :default_locale
                    [::I18n.default_locale]
                  when Symbol, String
                    [fallbacks.to_sym]
                  when Array
                    ensure_valid_fallbacks_as_array
                    fallbacks
                  when Hash
                    Array(fallbacks[locale] || default_fallbacks)
                  else
                    fail ArgumentError, "fallbacks must be: true, :default_locale an Array or a Hash - given: #{fallbacks}"
                  end
        locales.map! { |locale| locale.to_sym }
        ensure_valid_locales(locales)
      end

      private

      # Returns: An Array of locales.
      def default_fallbacks
        if i18n_fallbacks?
          I18n.fallbacks[locale]
        else
          [::I18n.default_locale]
        end
      end

      # Returns: true if we can safely use I18n.fallbacks, false otherwise.
      #
      # NOTE: We should implement this as `I18n.respond_to?(:fallbacks)`, but
      #       once I18n::Backend::Fallbacks is included, I18n will _always_
      #       respond to :fallbacks. Even if we switch the backend to one
      #       without fallbacks!
      #
      #       Maybe this should be fixed within I18n.
      def i18n_fallbacks?
        I18n.backend.class.included_modules.include?(I18n::Backend::Fallbacks)
      end

      def ensure_valid_fallbacks_as_array
        unless fallbacks.all? { |e| e.is_a?(String) || e.is_a?(Symbol) }
          fail ArgumentError, "If fallbacks is passed as Array, it must ony include Strings or Symbols. Given: #{fallbacks}"
        end
      end

      # Ensures that only valid locales are returned.
      def ensure_valid_locales(locales)
        if locales.any? { |locale| !::I18n.available_locales.include?(locale) }
          fail ArgumentError, "Valid locales: #{::I18n.available_locales} - Given Locales: #{locales}"
        end
        locales
      end

      # Workaround to allow some nice i18n-js.yml
      #
      # NOTE: Fallbacks might be an Array of Locales or an Array of Hashes.
      #       If it is an Array of Hashes (like when parsed from i18n-js.yml)
      #       it must be treated in a special way.
      def handle_fallbacks_as_array
        if fallbacks.all? { |e| e.is_a?(Hash) }
          array_with_hashes_to_fallbacks || default_fallbacks
        else
          fallbacks
        end
      end

      # Workaround to allow some nice i18n-js.yml
      #
      # Returns: The first hash for current locale.
      def array_with_hashes_to_fallbacks
        hash = fallbacks.select { |e| e.keys == [locale.to_s] }.first
        Array(hash[locale.to_s]) if hash
      end
    end # -- class Fallbacks
  end # -- module JS
end # -- module I18n
