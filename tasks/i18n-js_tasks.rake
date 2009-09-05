namespace :i18n do
  desc "Copy i18n.js and export the messages file"
  task :setup => :require_lib do
    SimplesIdeias::I18n.copy!
  end
  
  task :require_lib do
    require File.dirname(__FILE__) + "/../init"
  end
end
