module SimplesIdeias
  module I18n
    class Railtie < Rails::Railtie
      rake_tasks do
        require "i18n-js/rake"
      end

      config.to_prepare do
        SimplesIdeias::I18n.tap do |i18n|
          i18n.export! if i18n.auto_export?
        end
      end
    end
  end
end
