namespace :i18n do
  desc "Export the messages files"
  task :export do
    require "config/environment"
    SimplesIdeias::I18n.export!
  end
end
