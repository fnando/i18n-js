namespace :i18n do
  desc "Copy i18n.js and export the messages file"
  task :setup => :require_lib do
    SimplesIdeias::I18n.copy!
  end
  
  desc "Export the messages file"
  task :export do
    require "config/environment"
    SimplesIdeias::I18n.export!
  end
  
  task :require_lib do
    require File.dirname(__FILE__) + "/../init"
  end
end
