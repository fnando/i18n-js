require "i18n/js"

module I18n
  module JS
    class Engine < ::Rails::Engine
      initializer :after => "sprockets.environment" do
        next unless JS::Dependencies.using_asset_pipeline?
        next unless Rails.configuration.assets.compile

        Rails.application.assets.register_preprocessor "application/javascript", :"i18n-js_dependencies" do |context, source|
          if context.logical_path == "i18n/filtered"
            ::I18n.load_path.each {|path| context.depend_on(File.expand_path(path))}
          end
          source
        end
      end
    end
  end
end
