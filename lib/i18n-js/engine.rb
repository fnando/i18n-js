module SimplesIdeias
  module I18n
    # Engine so the vendor directory gets recognized by the asset pipeline
    class Engine < ::Rails::Engine
      I18N_TRANSLATIONS_ASSET = 'i18n/translations'

      initializer 'i18n-js.asset_dependencies', :after => "sprockets.environment" do
        config = Rails.root.join('config','i18n-js.yml')
        cache_file = I18n::Engine.load_path_hash_cache
        Rails.application.assets.register_preprocessor 'application/javascript', :'i18n-js_dependencies' do |ctx,data|
          if ctx.logical_path == I18N_TRANSLATIONS_ASSET
            ctx.depend_on(config)
            # also set up dependencies on every locale file
            ::I18n.load_path.each {|path| ctx.depend_on(path)}
            # Set up a dependency on the contents of the load path
            # itself.  In some situations it is possible to get here
            # before the path hash cache file has been written; in
            # this situation, write it now.
            I18n::Engine.write_hash! unless File.exists?(cache_file)
            ctx.depend_on(cache_file)
          end
          data
        end
      end

      # rewrite path cache hash at startup and before each request in development
      config.to_prepare do
        SimplesIdeias::I18n::Engine.write_hash_if_changed unless Rails.env.production?
      end

      class << self
        def load_path_hash_cache
          @load_path_hash_cache ||= File.join(Rails.application.paths['tmp'].first,'i18n-js.i18n_path_cache.dat')
        end

        attr_accessor :cached_load_path_hash

        # Rewrite path cache when it changes
        def write_hash_if_changed
          load_path_hash = ::I18n.load_path.hash
          if load_path_hash != cached_load_path_hash
            self.cached_load_path_hash = load_path_hash
            write_hash!
          end
        end
        
        def write_hash!
          File.open(load_path_hash_cache,'w') do |f| 
            f.write(cached_load_path_hash)
          end
        end
      end
    end
  end
end
