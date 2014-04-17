require "i18n/js"

module I18n
  module JS
    class Engine < ::Rails::Engine
      initializer :after => "sprockets.environment" do
        ActiveSupport.on_load(:after_initialize, :yield => true) do
          next unless JS::Dependencies.using_asset_pipeline?
          next unless Rails.configuration.assets.compile

          begin
            Rails.application.assets.register_preprocessor "application/javascript", :"i18n-js_dependencies" do |context, source|
              if context.logical_path == "i18n/filtered"
                ::I18n.load_path.each {|path| context.depend_on(File.expand_path(path))}
              end

              source
            end
          rescue TypeError # I don't think there is a more specific error to rescue
            # Could be raised by `Sprockets::Index`/`Sprockets::CachedEnvironment`
            # when doing `register_preprocessor` (which calls `expire_cache!` somehow)
            #
            # In that case it is immutable, we don't need to do anything
          end
        end
      end
    end
  end
end
