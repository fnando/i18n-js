# frozen_string_literal: true

def reset_i18n
  I18n.available_locales = ["en"]
  I18n.locale = "en"
  I18n.default_locale = "en"
  I18n.load_path = []
  I18n.backend = nil
  I18n.default_separator = nil
  I18n.enforce_available_locales = false
end
