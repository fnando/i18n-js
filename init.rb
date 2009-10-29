require File.dirname(__FILE__) + "/lib/i18n-js"

Rails.configuration.after_initialize do
  begin
    SimplesIdeias::I18n.export!
  rescue Exception
  end
end
