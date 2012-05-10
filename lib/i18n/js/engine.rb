require "i18n/js"

module I18n
  module JS
    class Engine < ::Rails::Engine
      initializer :after => "sprockets.environment" do
        path = File.expand_path("../../..", __FILE__)
        ::Rails.configuration.assets.paths.unshift(path) if JS.has_asset_pipeline?
      end

      ActiveSupport.on_load(:after_initialize, :yield => true) do
        next unless JS.has_asset_pipeline?
        next unless Rails.configuration.assets.compile

        Rails.application.assets.register_preprocessor "application/javascript", :"i18n-js_dependencies" do |context, source|
          next source unless context.logical_path == "i18n/translations"
          ::I18n.load_path.each {|path| context.depend_on(path)}
          source
        end
      end
    end
  end
end
