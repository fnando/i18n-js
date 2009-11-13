module SimplesIdeias
  module I18n
    extend self
    
    CONFIG_FILE = "#{RAILS_ROOT}/config/i18n-js.yml"
    
    def export!(config = load_config!)
      # Validity check of the config file
      if config["translations"].nil?
        puts "I18n-js: No translations to synchronize, define them in your config/i18n-js.yml." if Rails.env.development?
        return
      end

      ::I18n.backend.__send__ :init_translations
      config["translations"].each do |name, file_config|
        export_translations!(name, file_config) unless file_config.nil?
      end
    end

    # Will run at every boot of the app
    def setup!
      # Copy config file if not already present
      copy_config!

      # Load config to copy i18n.js to the desired location
      config = load_config!

      # Validity check of the config file
      raise "

      --- I18n-js ---
      i18n_dir shall be defined in your config/i18n-js.yml.
      You can simply delete config/i18n-js.yml to restore it as default.
      ---------------
      " if config["i18n_dir"].nil?

      # Copy the i18n.js file to the user desired location
      copy_js!(config["i18n_dir"])

      export!(config)
    end

    private

      def copy_config!
        unless File.exist?(CONFIG_FILE)
          File.open(CONFIG_FILE, "w+") do |f|
            f << File.read(File.dirname(__FILE__) + "/i18n-js.yml")
          end
        end
      end

      def copy_js!(dir)
        File.open(RAILS_ROOT + "/" + dir + "/i18n.js", "w+") do |f|
          f << File.read(File.dirname(__FILE__) + "/i18n.js")
        end
      end

      def export_translations!(name, file_config)
        return puts("I18n-js: #{name} exportation skipped as no file specified in config/i18n-js.yml") if file_config["file"].blank?

        if file_config.has_key?("only")
          if file_config["only"].is_a?(String)
            translations = get_translations_only_for(::I18n.backend.__send__(:translations), file_config["only"])
          else
            translations = {}

            # deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
            merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
            for scope in file_config["only"]
              result = get_translations_only_for(::I18n.backend.__send__(:translations), scope)
              translations.merge!(result, &merger) unless result.nil?
            end
          end
        else
          translations = ::I18n.backend.__send__(:translations)
        end
        File.open(RAILS_ROOT + "/" + file_config["file"], "w+") do |f|
          f << %(var I18n = I18n || {};\n)
          f << %(I18n.translations = );
          f << translations.to_json
          f << %(;)
        end
      end

      def get_translations_only_for(translations, scopes)
        scopes = scopes.split(".") if scopes.is_a?(String)
        scopes = scopes.clone
        scope = scopes.shift

        if scope == "*"
          results = {}
          translations.each do |scope, translations|
            tmp = scopes.empty? ? translations : get_translations_only_for(translations, scopes)
            results[scope.to_sym] = tmp unless tmp.nil?
          end
          return results
        elsif translations.has_key?(scope.to_sym)
          return {scope.to_sym => scopes.empty? ? translations[scope.to_sym] : get_translations_only_for(translations[scope.to_sym], scopes)}
        end
        nil
      end

      def load_config!
        YAML.load(File.open(CONFIG_FILE))
      end
  end
end
