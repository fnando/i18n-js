module SimplesIdeias
  module I18n
    extend self
    
    CONFIG_FILE = "#{RAILS_ROOT}/config/i18n-js.yml"
    INVALID_I18N_DIR = "

    --- I18n-js ---
    i18n_dir shall be defined in your config/i18n-js.yml.
    You can simply delete config/i18n-js.yml to restore it as default.
    ---------------
    "
    
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
      # Copy (if needed) and load config
      config = load_config!

      # Validity check of the config file
      raise INVALID_I18N_DIR if config["i18n_dir"].nil?

      # Copy the i18n.js file to the user desired location
      copy_js!(config["i18n_dir"])

      export!(config)
    end

    private

      def copy_config!
        if File.exist?(CONFIG_FILE)
          puts "Skipped i18n-js.yml as already present."
        else
          File.open(CONFIG_FILE, "w+") do |f|
            f << File.read(File.dirname(__FILE__) + "/i18n-js.yml")
          end
          puts "Copied i18n-js.yml at #{CONFIG_FILE}."
        end
      end

      def copy_js!(dir)
        File.open(RAILS_ROOT + "/" + dir + "/i18n.js", "w+") do |f|
          f << File.read(File.dirname(__FILE__) + "/i18n.js")
        end
        puts "Copied i18n.js at #{RAILS_ROOT}/#{dir}/i18n.js."
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
          f << convert_hash_to_ordered_hash_and_sort(translations, true).to_json
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
        # Copy config file if not already present
        copy_config!

        YAML.load(File.open(CONFIG_FILE))
      end

      def convert_hash_to_ordered_hash_and_sort(object, deep = false)
        if object.is_a?(Hash)
          # Hash is ordered in Ruby 1.9!
          res = returning(RUBY_VERSION >= '1.9' ? Hash.new : ActiveSupport::OrderedHash.new) do |map|
            object.each {|k, v| map[k] = deep ? convert_hash_to_ordered_hash_and_sort(v, deep) : v }
          end
          return res.class[res.sort {|a, b| a[0].to_s <=> b[0].to_s } ]
        elsif deep && object.is_a?(Array)
          array = Array.new
          object.each_with_index {|v, i| array[i] = convert_hash_to_ordered_hash_and_sort(v, deep) }
          return array
        else
          return object
        end
      end
  end
end
