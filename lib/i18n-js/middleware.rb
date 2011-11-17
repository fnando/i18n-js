module SimplesIdeias
  module I18n
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        @cache = nil
        verify_locale_files!
        @app.call(env)
      end

      private
      def cache_path
        @cache_path ||= Rails.root.join("tmp/cache/i18n-js.yml")
      end

      def cache
        @cache ||= begin
          if cache_path.exist?
            YAML.load_file(cache_path) || {}
          else
            {}
          end
        end
      end

      # Check if translations should be regenerated.
      # ONLY REGENERATE when these conditions are met:
      #
      # # Cache file doesn't exist
      # # Translations and cache size are different (files were removed/added)
      # # Translation file has been updated
      #
      def verify_locale_files!
        valid_cache = []
        new_cache = {}

        valid_cache.push cache_path.exist?
        valid_cache.push ::I18n.load_path.uniq.size == cache.size

        ::I18n.load_path.each do |path|
          changed_at = File.mtime(path).to_i
          valid_cache.push changed_at == cache[path]
          new_cache[path] = changed_at
        end

        unless valid_cache.all?
          File.open(cache_path, "w+") do |file|
            file << new_cache.to_yaml
          end

          SimplesIdeias::I18n.export!
        end
      end
    end
  end
end
