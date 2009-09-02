namespace :i18n do
  desc "Generate the messages file"
  task :generate => :require_lib do
    SimplesIdeias::I18n.export!
  end
  
  desc "Copy i18n.js and export the messages file"
  task :setup => :generate do
    SimplesIdeias::I18n.copy!
  end
  
  task :require_lib do
    require File.dirname(__FILE__) + "/../init"
  end
end
