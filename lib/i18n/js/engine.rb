require "i18n/js"

module I18n
  module JS
    class Engine < ::Rails::Engine
      # `sprockets.environment` was used for 1.x of `sprockets-rails`
      # https://github.com/rails/sprockets-rails/issues/227
      #
      # References for current values:
      #
      # Here is where sprockets are attached with Rails. There is no 'sprockets.environment' mentioned.
      # https://github.com/rails/sprockets-rails/blob/master/lib/sprockets/railtie.rb
      #
      # Finisher hook is the place which should be used as border.
      # http://guides.rubyonrails.org/configuring.html#initializers
      #
      # For detail see Pull Request:
      # https://github.com/fnando/i18n-js/pull/371
      initializer "i18n-js.register_preprocessor", after: :engines_blank_point, before: :finisher_hook do
        next unless JS::Dependencies.using_asset_pipeline?
        next unless JS::Dependencies.sprockets_supports_register_preprocessor?

        # From README of 2.x & 3.x of `sprockets-rails`
        # It seems the `configure` block is preferred way to call `register_preprocessor`
        # Not sure if this will break older versions of rails
        #
        # https://github.com/rails/sprockets-rails/blob/v2.3.3/README.md
        # https://github.com/rails/sprockets-rails/blob/v3.0.0/README.md
        Rails.application.config.assets.configure do |config|
          config.register_preprocessor "application/javascript", :"i18n-js_dependencies" do |context, source|
            if context.logical_path == "i18n/filtered"
              ::I18n.load_path.each {|path| context.depend_on(File.expand_path(path))}
            end
            source
          end
        end
      end
    end
  end
end
