module SimplesIdeias
  module I18n
    class Railtie < Rails::Railtie
      rake_tasks do
        require "i18n-js/rake"
      end

      initializer "i18n-js.initialize" do |app|
        app.config.middleware.use(Middleware) if Rails.env.development? && !Rails.configuration.assets.enabled
      end
    end
  end
end
