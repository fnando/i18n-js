require "yaml"
require "i18n"
require "fileutils"
require "i18n/js/utils"
require "i18n/js/dependencies"
require "i18n/js/fallback_locales"
require "i18n/js/segment"
require "i18n/js/exporter"

if I18n::JS::Dependencies.rails?
  require "i18n/js/middleware"
  require "i18n/js/engine"
end

# Public interface
module I18n
  module JS
    def self.export
      I18n::JS::Exporter.export
    end

    def self.filtered_translations
      I18n::JS::Exporter.filtered_translations
    end

    def self.config_file_path=(value)
      I18n::JS::Exporter.config_file_path = value
    end

    def self.export_i18n_js_dir_path=(value)
      I18n::JS::Exporter.export_i18n_js_dir_path = value
    end
  end
end
