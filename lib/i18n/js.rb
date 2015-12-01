require "yaml"
require "i18n"
require "fileutils"
require "i18n/js/configuration"
require "i18n/js/configuration/yaml_file_loader"
require "i18n/js/utils"

module I18n
  module JS
    require "i18n/js/dependencies"
    require "i18n/js/fallback_locales"
    require "i18n/js/segment"
    if JS::Dependencies.rails?
      require "i18n/js/middleware"
      require "i18n/js/engine"
    end

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   I18n::JS.configure do |config|
    #     config.some_config = some_value
    #   end
    def self.configure
      yield(configuration)
      self
    end

    # The configuration object.
    #
    # @see I18n::JS.configure
    def self.configuration
      @configuration ||= Configuration.new
    end

    # Export translations to JavaScript, considering settings
    # from configuration file
    def self.export
      export_i18n_js

      translation_segments.each(&:save!)
    end

    def self.segment_for_scope(scope, exceptions)
      if scope == "*"
        exclude(translations, exceptions)
      else
        scoped_translations(scope, exceptions)
      end
    end

    # deep_merge! given result with result for fallback locale
    def self.merge_with_fallbacks!(result)
      I18n.available_locales.each do |locale|
        fallback_locales = FallbackLocales.new(configuration.fallbacks, locale)
        fallback_locales.each do |fallback_locale|
          # `result[fallback_locale]` could be missing
          result[locale] = Utils.deep_merge(result[fallback_locale] || {}, result[locale] || {})
        end
      end
    end

    def self.filtered_translations
      translations = {}.tap do |result|
        translation_segments.each do |segment|
          Utils.deep_merge!(result, segment.translations)
        end
      end
      return Utils.deep_key_sort(translations) if I18n::JS.configuration.sort_translation_keys?
      translations
    end

    def self.translation_segments
      configuration.translation_segment_settings.inject([]) do |segments, options|
        file = options[:file]
        only = options[:only] || '*'
        exceptions = [options[:except] || []].flatten

        segment_options = options.slice(:namespace, :pretty_print)

        result = segment_for_scope(only, exceptions)

        merge_with_fallbacks!(result) if configuration.use_fallbacks?

        segments << Segment.new(file, result, segment_options) unless result.empty?

        segments
      end
    end

    def self.scoped_translations(scopes, exceptions = []) # :nodoc:
      result = {}

      [scopes].flatten.each do |scope|
        translations_without_exceptions = exclude(translations, exceptions)
        filtered_translations = filter(translations_without_exceptions, scope) || {}

        Utils.deep_merge!(result, filtered_translations)
      end

      result
    end

    # Exclude keys from translations listed in the `except:` section in the config file
    def self.exclude(translations, exceptions)
      return translations if exceptions.empty?

      exceptions.inject(translations) do |memo, exception|
        exception_scopes = exception.to_s.split(".")
        Utils.deep_reject(memo) do |key, value, scopes|
          Utils.scopes_match?(scopes, exception_scopes)
        end
      end
    end

    # Filter translations according to the specified scope.
    def self.filter(translations, scopes)
      scopes = scopes.split(".") if scopes.is_a?(String)
      scopes = scopes.clone
      scope = scopes.shift

      if scope == "*"
        results = {}
        translations.each do |scope, translations|
          tmp = scopes.empty? ? translations : filter(translations, scopes)
          results[scope.to_sym] = tmp unless tmp.nil?
        end
        return results
      elsif translations.respond_to?(:has_key?) && translations.has_key?(scope.to_sym)
        return {scope.to_sym => scopes.empty? ? translations[scope.to_sym] : filter(translations[scope.to_sym], scopes)}
      end
      nil
    end

    # Initialize and return translations
    def self.translations
      ::I18n.backend.instance_eval do
        init_translations unless initialized?
        translations.slice(*::I18n.available_locales)
      end
    end

    ### Export i18n.js
    begin

      # Copy i18n.js
      def self.export_i18n_js
        return unless configuration.export_i18n_js?
        export_i18n_js_dir_path = configuration.export_i18n_js_dir_path

        FileUtils.mkdir_p(export_i18n_js_dir_path)

        i18n_js_path = File.expand_path('../../../app/assets/javascripts/i18n.js', __FILE__)
        FileUtils.cp(i18n_js_path, export_i18n_js_dir_path)
      end
    end
  end
end
