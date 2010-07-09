module SimplesIdeias
  module I18n
    class Railtie < Rails::Railtie
      rake_tasks do
        load File.dirname(__FILE__) + "/../tasks/i18n-js_tasks.rake"
      end
    end
  end
end
