require File.dirname(__FILE__) + "/lib/i18n-js"

Rails.configuration.after_initialize do
  SimplesIdeias::I18n.setup!
end
