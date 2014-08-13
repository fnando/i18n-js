require "i18n"
require "fileutils"

require "i18n/js/utils"

module I18n
  module JS
    require "i18n/js/dependencies"
    if JS::Dependencies.rails?
      require "i18n/js/middleware"
      require "i18n/js/engine"
    end

    DEFAULT_CONFIG_PATH = "config/i18n-js.yml"

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

      translation_segments.each do |filename, translations|
        save(translations, filename)
      end
    end

    def self.segments_per_locale(pattern, scope)
      I18n.available_locales.each_with_object({}) do |locale, segments|
        scope = [scope] unless scope.respond_to?(:each)
        result = scoped_translations(scope.collect{|s| "#{locale}.#{s}"})
        next if result.empty?

        segment_name = ::I18n.interpolate(pattern,{:locale => locale})
        segments[segment_name] = result
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
      config[:translations].each_with_object({}) do |options, segments|
        options.reverse_merge!(:only => "*")
        if options[:file] =~ ::I18n::INTERPOLATION_PATTERN
          segments.merge!(segments_per_locale(options[:file], options[:only]))
        else
          result = segment_for_scope(options[:only])
          segments[options[:file]] = result unless result.empty?
        end
      end
    end

    def self.default_export_dir_path
      "public/javascripts"
    end

    def self.filtered_translations
      {}.tap do |result|
        translation_segments.each do |filename, translations|
          Utils.deep_merge!(result, translations)
        end
      end
    end

    def self.translation_segments
      if config? && config[:translations]
        configured_segments
      else
        {"#{default_export_dir_path}/translations.js" => translations}
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

    # Convert translations to JSON string and save file.
    def self.save(translations, file)
      FileUtils.mkdir_p File.dirname(file)

      File.open(file, "w+") do |f|
        f << %(I18n.translations || (I18n.translations = {});\n)
        Utils.strip_keys_with_nil_values(translations).each do |locale, translations_for_locale|
          f << %(I18n.translations["#{locale}"] = #{translations_for_locale.to_json};\n);
        end
      end
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

        @export_i18n_js_dir_path = default_export_dir_path
      end
      # Setting this to nil would disable i18n.js exporting
      def self.export_i18n_js_dir_path=(new_path)
        @export_i18n_js_dir_path = new_path
      end
    end
  end
end
