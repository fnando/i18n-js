module SimplesIdeias
  module I18n
    class Engine < ::Rails::Engine
      I18N_TRANSLATIONS_ASSET = "i18n/translations"

      initializer "i18n-js.asset_dependencies", :after => "sprockets.environment" do
        next unless SimplesIdeias::I18n.has_asset_pipeline?

        config = Rails.root.join("config", "i18n-js.yml")
        cache_file = I18n::Engine.load_path_hash_cache

        Rails.application.assets.register_preprocessor "application/javascript", :"i18n-js_dependencies" do |context, data|
          if context.logical_path == I18N_TRANSLATIONS_ASSET
            context.depend_on(config)
            # also set up dependencies on every locale file
            ::I18n.load_path.each {|path| context.depend_on(path)}

            # Set up a dependency on the contents of the load path
            # itself. In some situations it is possible to get here
            # before the path hash cache file has been written; in
            # this situation, write it now.
            I18n::Engine.write_hash! unless File.exists?(cache_file)
            context.depend_on(cache_file)
          end

          data
        end
      end

      # rewrite path cache hash at startup and before each request in development
      config.to_prepare do
        next unless SimplesIdeias::I18n.has_asset_pipeline?
        SimplesIdeias::I18n::Engine.write_hash_if_changed unless Rails.env.production?
      end

      def self.load_path_hash_cache
        @load_path_hash_cache ||= Rails.root.join("tmp/i18n-js.cache")
      end

      def self.write_hash_if_changed
        load_path_hash = ::I18n.load_path.hash

        if load_path_hash != cached_load_path_hash
          self.cached_load_path_hash = load_path_hash
          write_hash!
        end
      end

      def self.write_hash!
        FileUtils.mkdir_p Rails.root.join("tmp")

        File.open(load_path_hash_cache, "w+") do |f|
          f.write(cached_load_path_hash)
        end
      end

      class << self
        attr_accessor :cached_load_path_hash
      end
    end
  end
end
