require "i18n"
require "fileutils"

module I18n
  module JS
    require "i18n/js/dependencies"
    require "i18n/js/segment"
    if JS::Dependencies.rails?
      require "i18n/js/middleware"
      require "i18n/js/engine"
    end

    # deep_merge by Stefan Rusterholz, see <http://www.ruby-forum.com/topic/142809>.
    MERGER = proc do |key, v1, v2|
      Hash === v1 && Hash === v2 ? v1.merge(v2, &MERGER) : v2
    end

    # The configuration file. This defaults to the `config/i18n-js.yml` file.
    #
    def self.config_file
      @config_file ||= "config/i18n-js.yml"
    end

    # Export translations to JavaScript, considering settings
    # from configuration file
    def self.export
      translation_segments.each(&:save!)
    end

    def self.segments_per_locale(pattern, scope, namespace)
      I18n.available_locales.each_with_object([]) do |locale, segments|
        result = scoped_translations("#{locale}.#{scope}")
        next if result.empty?
        segments << Segment.new(::I18n.interpolate(pattern,{:locale => locale}), result, namespace)
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
        options.reverse_merge!(:only => "*")
        if options[:file] =~ ::I18n::INTERPOLATION_PATTERN
          segments += segments_per_locale(options[:file], options[:only], options[:namespace])
        else
          result = segment_for_scope(options[:only])
          segments << Segment.new(options[:file], result, options[:namespace]) unless result.empty?
        end
        segments
      end
    end

    def self.export_dir
      "public/javascripts"
    end

    def self.filtered_translations
      {}.tap do |result|
        translation_segments.each do |file, translations|
          deep_merge!(result, translations)
        end
      end
    end

    def self.translation_segments
      if config? && config[:translations]
        configured_segments
      else
        [Segment.new("#{export_dir}/translations.js", translations)]
      end
    end

    # Load configuration file for partial exporting and
    # custom output directory
    def self.config
      if config?
        (YAML.load_file(config_file) || {}).with_indifferent_access
      else
        {}
      end
    end

    # Check if configuration file exist
    def self.config?
      File.file? config_file
    end

    def self.scoped_translations(scopes) # :nodoc:
      result = {}

      [scopes].flatten.each do |scope|
        deep_merge! result, filter(translations, scope)
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
      elsif translations.has_key?(scope.to_sym)
        return {scope.to_sym => scopes.empty? ? translations[scope.to_sym] : filter(translations[scope.to_sym], scopes)}
      end
      nil
    end

    # Initialize and return translations
    def self.translations
      ::I18n.backend.instance_eval do
        init_translations unless initialized?
        translations
      end
    end

    def self.deep_merge(target, hash) # :nodoc:
      target.merge(hash, &MERGER)
    end

    def self.deep_merge!(target, hash) # :nodoc:
      target.merge!(hash, &MERGER)
    end
  end
end
