module SimplesIdeias
  module I18n
    extend self
    
    CONFIG_FILE = "#{RAILS_ROOT}/config/i18n-js.yml"
    
    def export!
      config = load_config!

      # Validity check of the config file
      if config["translations"].nil?
        puts "I18n-js: No translations to synchronize, define them in your config/i18n-js.yml." if Rails.env.development?
        return
      end

      ::I18n.backend.__send__ :init_translations
      config["translations"].each do |name, file_config|
        export_translations!(file_config["file"], file_config["scope"])
      end
    end
    
    # To use with rake i18n:setup
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
        File.open(dir + "/i18n.js", "w+") do |f|
          f << File.read(File.dirname(__FILE__) + "/i18n.js")
        end
      end

##### FIXME: Wrong approach
# Check http://github.com/svenfuchs/i18n/blob/master/lib/i18n/backend/base.rb for ::I18n::backend.merge_translations
      def get_translations(scope)
        result = []
        ::I18n.backend.__send__(:translations).each do |local, translations|
          result << {local => hash_deep_fetch(translations, scope.split("."))}
        end
        result
      end

      def export_translations!(file, scope)
        result = []
        if scope.class == String
          result << get_translations(scope)
        elsif scope.class == Array
          scope.each do |scope|
            result << get_translations(scope)
          end
        end

        # File.open(JAVASCRIPT_DIR + "/messages.js", "w+") do |f|
        #   f << %(var I18n = I18n || {};\n)
        #   f << %(I18n.translations = );
        #   f << ::I18n.backend.__send__(:translations).to_json
        #   f << %(;)
        # end
      end
#####

      def load_config!
        YAML.load(File.open(CONFIG_FILE))
      end

      # FIXME: Not sure it's still needed as based on a wrong approach
      #
      # Retrieve an hash value based on an array of scopes
      #
      # If no values is found, it return nil
      #
      # eg: hash_deep_fetch({"parent" => {"child" => "value"}}, ["parent", "child"])
      # -> "value"
      def hash_deep_fetch(hash, scope)
        return nil if hash.nil?
        return(hash[scope.to_sym]) if scope.class == String || (scope.class == Array && scope.length == 1 && scope = scope.shift)
        hash_deep_fetch(hash[scope.shift.to_sym], scope)
      end
  end
end
