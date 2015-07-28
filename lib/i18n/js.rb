require "yaml"
require "i18n"
require "fileutils"
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

    DEFAULT_CONFIG_PATH = "config/i18n-js.yml"
    DEFAULT_EXPORT_DIR_PATH = "public/javascripts"

    # The configuration file. This defaults to the `config/i18n-js.yml` file.
    #
    def self.config_file_path
      @config_file_path ||= DEFAULT_CONFIG_PATH
    end

    def self.config_file_path=(new_path)
      @config_file_path = new_path
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

    def self.configured_segments
      config[:translations].inject([]) do |segments, options|
        file = options[:file]
        only = options[:only] || '*'
        exceptions = [options[:except] || []].flatten

        segment_options = options.slice(:namespace, :pretty_print)

        result = segment_for_scope(only, exceptions)

        merge_with_fallbacks!(result) if fallbacks

        segments << Segment.new(file, result, segment_options) unless result.empty?

        segments
      end
    end

    # deep_merge! given result with result for fallback locale
    def self.merge_with_fallbacks!(result)
      I18n.available_locales.each do |locale|
        fallback_locales = FallbackLocales.new(fallbacks, locale)
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
      return Utils.deep_key_sort(translations) if I18n::JS.sort_translation_keys?
      translations
    end

    def self.translation_segments
      if config? && config[:translations]
        configured_segments
      else
        [Segment.new("#{export_i18n_js_dir_path}/translations.js", translations)]
      end
    end

    # Load configuration file for partial exporting and
    # custom output directory
    def self.config
      if config?
        erb = ERB.new(File.read(config_file_path)).result
        (YAML.load(erb) || {}).with_indifferent_access
      else
        {}
      end
    end

    # Check if configuration file exist
    def self.config?
      File.file? config_file_path
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

    def self.use_fallbacks?
      fallbacks != false
    end

    def self.fallbacks
      config.fetch(:fallbacks) do
        # default value
        true
      end
    end

    def self.sort_translation_keys?
      @sort_translation_keys ||= (config[:sort_translation_keys]) if config.has_key?(:sort_translation_keys)
      @sort_translation_keys = true if @sort_translation_keys.nil?
      @sort_translation_keys
    end

    def self.sort_translation_keys=(value)
      @sort_translation_keys = !!value
    end

    ### Export i18n.js
    begin

      # Copy i18n.js
      def self.export_i18n_js
        return unless export_i18n_js_dir_path.is_a? String

        FileUtils.mkdir_p(export_i18n_js_dir_path)

        i18n_js_path = File.expand_path('../../../app/assets/javascripts/i18n.js', __FILE__)
        FileUtils.cp(i18n_js_path, export_i18n_js_dir_path)
      end

      def self.export_i18n_js_dir_path
        @export_i18n_js_dir_path ||= (config[:export_i18n_js] || :none) if config.has_key?(:export_i18n_js)
        @export_i18n_js_dir_path ||= DEFAULT_EXPORT_DIR_PATH
        @export_i18n_js_dir_path
      end

      # Setting this to nil would disable i18n.js exporting
      def self.export_i18n_js_dir_path=(new_path)
        new_path = :none unless new_path.is_a? String
        @export_i18n_js_dir_path = new_path
      end
    end
  end
end
