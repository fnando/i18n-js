require "FileUtils" unless defined?(FileUtils)

module SimplesIdeias
  module I18n
    extend self

    require "i18n-js/railtie" if Rails.version >= "3.0"
    require "i18n-js/engine" if Rails.version >= "3.1"
    require "i18n-js/middleware"

    # deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
    MERGER = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &MERGER) : v2 }

    # Under rails 3.1.1 and higher, perform a check to ensure that the
    # full environment will be available during asset compilation.
    # This is required to ensure I18n is loaded.
    def assert_usable_configuration!
      @usable_configuration ||= Rails.version >= "3.1.1" &&
        Rails.configuration.assets.initialize_on_precompile ||
        raise("Cannot precompile i18n-js translations unless environment is initialized. Please set config.assets.initialize_on_precompile to true.")
    end

    def has_asset_pipeline?
      Rails.configuration.respond_to?(:assets) && Rails.configuration.assets.enabled
    end

    def config_file
      Rails.root.join("config/i18n-js.yml")
    end

    def export_dir
      if has_asset_pipeline?
        "app/assets/javascripts/i18n"
      else
        "public/javascripts"
      end
    end

    def javascript_file
      Rails.root.join(export_dir, "i18n.js")
    end

    # Export translations to JavaScript, considering settings
    # from configuration file
    def export!
      translation_segments.each do |filename, translations|
        save(translations, filename)
      end
    end

    def segments_per_locale(pattern,scope)
      ::I18n.available_locales.each_with_object({}) do |locale,segments|
        result = scoped_translations("#{locale}.#{scope}")
        unless result.empty?
          segment_name = ::I18n.interpolate(pattern,{:locale => locale})
          segments[segment_name] = result
        end
      end
    end

    def segment_for_scope(scope)
      if scope == "*"
        translations
      else
        scoped_translations(scope)
      end
    end

    def configured_segments
      config[:translations].each_with_object({}) do |options,segments|
        options.reverse_merge!(:only => "*")
        if options[:file] =~ ::I18n::INTERPOLATION_PATTERN
          segments.merge!(segments_per_locale(options[:file],options[:only]))
        else
          result = segment_for_scope(options[:only])
          segments[options[:file]] = result unless result.empty?
        end
      end
    end

    def translation_segments
      if config? && config[:translations]
        configured_segments
      else
        {"#{export_dir}/translations.js" => translations}
      end
    end

    # Load configuration file for partial exporting and
    # custom output directory
    def config
      if config?
        (YAML.load_file(config_file) || {}).with_indifferent_access
      else
        {}
      end
    end

    # Check if configuration file exist
    def config?
      File.file? config_file
    end

    # Copy configuration and JavaScript library files to
    # <tt>config/i18n-js.yml</tt> and <tt>public/javascripts/i18n.js</tt>.
    def setup!
      FileUtils.cp(File.dirname(__FILE__) + "/../vendor/assets/javascripts/i18n.js", javascript_file) unless Rails.version >= "3.1"
      FileUtils.cp(File.dirname(__FILE__) + "/../config/i18n-js.yml", config_file) unless config?
    end

    # Retrieve an updated JavaScript library from Github.
    def update!
      require "open-uri"
      contents = open("https://raw.github.com/fnando/i18n-js/master/vendor/assets/javascripts/i18n.js").read
      File.open(javascript_file, "w+") {|f| f << contents}
    end

    # Convert translations to JSON string and save file.
    def save(translations, file)
      file = Rails.root.join(file)
      FileUtils.mkdir_p File.dirname(file)

      File.open(file, "w+") do |f|
        f << %(var I18n = I18n || {};\n)
        f << %(I18n.translations = );
        f << translations.to_json
        f << %(;)
      end
    end

    def scoped_translations(scopes) # :nodoc:
      result = {}

      [scopes].flatten.each do |scope|
        deep_merge! result, filter(translations, scope)
      end

      result
    end

    # Filter translations according to the specified scope.
    def filter(translations, scopes)
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
    def translations
      ::I18n.backend.instance_eval do
        init_translations unless initialized?
        translations
      end
    end

    def deep_merge(target, hash) # :nodoc:
      target.merge(hash, &MERGER)
    end

    def deep_merge!(target, hash) # :nodoc:
      target.merge!(hash, &MERGER)
    end
  end
end

