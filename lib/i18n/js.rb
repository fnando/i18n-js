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

    def self.segments_per_locale(pattern, scope, options)
      I18n.available_locales.each_with_object([]) do |locale, segments|
        scope = [scope] unless scope.respond_to?(:each)
        result = scoped_translations(scope.collect{|s| "#{locale}.#{s}"})
        merge_with_fallbacks!(result, locale, scope) if use_fallbacks?

        next if result.empty?
        segments << Segment.new(::I18n.interpolate(pattern, {:locale => locale}), result, options)
      end
    end

    def self.segment_for_scope(scope)
      if scope == "*"
        translations
      else
        scoped_translations(scope)
      end
    end

    def self.configured_segments
      config[:translations].inject([]) do |segments, options|
        file = options[:file]
        only = options[:only] || '*'
        segment_options = options.slice(:namespace, :pretty_print)

        if file =~ ::I18n::INTERPOLATION_PATTERN
          segments += segments_per_locale(file, only, segment_options)
        else
          result = segment_for_scope(only)
          segments << Segment.new(file, result, segment_options) unless result.empty?
        end
        segments
      end
    end

    def self.filtered_translations
      {}.tap do |result|
        translation_segments.each do |segment|
          Utils.deep_merge!(result, segment.translations)
        end
      end
    end

    def self.translation_segments
      if config? && config[:translations]
        configured_segments
      else
        [Segment.new("#{DEFAULT_EXPORT_DIR_PATH}/translations.js", translations)]
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

    def self.scoped_translations(scopes) # :nodoc:
      result = {}

      [scopes].flatten.each do |scope|
        Utils.deep_merge! result, filter(translations, scope)
      end

      result
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

    # deep_merge! given result with result for fallback locale
    def self.merge_with_fallbacks!(result, locale, scope)
      result[locale] ||= {}
      fallback_locales = FallbackLocales.new(fallbacks, locale)

      fallback_locales.each do |fallback_locale|
        fallback_result = scoped_translations(scope.collect{|s| "#{fallback_locale}.#{s}"}) # NOTE: Duplicated code here
        result[locale] = Utils.deep_merge(fallback_result[fallback_locale], result[locale])
      end
    end


    ### Export i18n.js
    begin
      # Copy i18n.js
      def self.export_i18n_js
        return if export_i18n_js_dir_path.nil?

        FileUtils.mkdir_p(export_i18n_js_dir_path)

        i18n_js_path = File.expand_path('../../../app/assets/javascripts/i18n.js', __FILE__)
        FileUtils.cp(i18n_js_path, export_i18n_js_dir_path)
      end
      def self.export_i18n_js_dir_path
        return @export_i18n_js_dir_path if defined?(@export_i18n_js_dir_path)

        @export_i18n_js_dir_path = DEFAULT_EXPORT_DIR_PATH
      end
      # Setting this to nil would disable i18n.js exporting
      def self.export_i18n_js_dir_path=(new_path)
        @export_i18n_js_dir_path = new_path
      end
    end
  end
end
