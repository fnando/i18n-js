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

      def verify_locale_files!
        valid_cache = []
        changed_files = []

        valid_cache.push cache_path.exist?
        valid_cache.push ::I18n.load_path.uniq.size == cache.size # use uniq because load_path may have duplicated values

        ::I18n.load_path.each do |path|
          change = File.mtime(path).to_i
          file_has_changed = change != cache[path]
          valid_cache.push file_has_changed
          valid_cache.push !file_has_changed # push true if the file has NOT changed
          changed_files << path if file_has_changed
          cache[path] = change
        end

        # Only write to the cache and export the translations if the cache has changed
        unless valid_cache.all?
          File.open(cache_path, "w+") do |file|
            file << cache.to_yaml           
          end          

          SimplesIdeias::I18n.export!     
        end
      end
    end
  end
end
