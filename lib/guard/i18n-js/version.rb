# frozen_string_literal: true

gem "guard"
gem "guard-compat"
require "guard/compat/plugin"

require "i18n-js"

module Guard
  class I18njsVersion < Plugin
    VERSION = I18nJS::VERSION
  end
end
