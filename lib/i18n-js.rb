module SimplesIdeias
  module I18n
    extend self

    # deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
    MERGER = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &MERGER) : v2 }

    # Load configuration file for partial exporting and
    # custom output directory
    CONFIG_FILE = Rails.root.join("config/i18n-js.yml")

    # Export translations to JavaScript, considering settings
    # from configuration file
    def export!
      if config?
        for options in config[:translations]
          options.reverse_merge!(:only => "*")

          if options[:only] == "*"
            save translations, options[:file]
          else
            result = scoped_translations(options[:only])
            save result, options[:file] unless result.empty?
          end
        end
      else
        save translations, "public/javascripts/messages.js"
      end
    end

    # Load configuration file
    def config
      HashWithIndifferentAccess.new YAML.load_file(CONFIG_FILE)
    end

    # Check if configuration file exist
    def config?
      File.file? CONFIG_FILE
    end

    # Copy configuration and JavaScript library files to
    # <tt>SimplesIdeias::I18n::CONFIG_FILE</tt> and <tt>public/i18n.js</tt>.
    def setup!
      FileUtils.cp File.dirname(__FILE__) + "/i18n-js.yml", CONFIG_FILE
      FileUtils.cp File.dirname(__FILE__) + "/i18n.js", Rails.root.join("public/i18n.js")
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

    def scoped_translations(scopes)
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
