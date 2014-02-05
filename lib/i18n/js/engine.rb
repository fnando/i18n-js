require "i18n/js"

module I18n
  module JS
    class Engine < ::Rails::Engine
      initializer :after => "sprockets.environment" do
        ActiveSupport.on_load(:after_initialize, :yield => true) do
          next unless JS.has_asset_pipeline?
          next unless Rails.configuration.assets.compile
          next unless %w[development test].include? Rails.env

          registry = Sprockets.respond_to?("register_preprocessor") ? Sprockets : Rails.application.assets

          registry.register_preprocessor "application/javascript", :"i18n-js_dependencies" do |context, source|
            next source unless context.logical_path == "i18n/filtered"
            ::I18n.load_path.each {|path| context.depend_on(File.expand_path(path))}
            source
          end
        end
      end
    end
  end
end
