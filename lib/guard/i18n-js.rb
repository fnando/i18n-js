# frozen_string_literal: true

gem "guard"
gem "guard-compat"
require "guard/compat/plugin"

require "i18n-js"

module Guard
  class I18njs < Plugin
    attr_reader :config_file, :require_file, :current_thread

    def initialize(options = {})
      @config_file = options.delete(:config_file)
      @require_file = options.delete(:require_file)
      super
    end

    def start
      export_files
    end

    def stop
      current_thread&.exit
    end

    def reload
      export_files
    end

    def run_all
      export_files
    end

    def run_on_additions(paths)
      export_files(paths)
    end

    def run_on_modifications(paths)
      export_files(paths)
    end

    def run_on_removals(paths)
      export_files(paths)
    end

    def export_files(changes = nil)
      return unless validate_file(:config_file, config_file)
      return unless validate_file(:require_file, require_file)

      current_thread&.exit

      info("Changes detected: #{changes.join(', ')}") if changes

      @current_thread = Thread.new do
        require @require_file
        ::I18nJS.call(config_file: @config_file)
      end

      current_thread.join
    end

    def validate_file(key, file)
      return true if file && File.file?(file)

      error("#{key.inspect} must be a file")
      false
    end

    def error(message)
      ::Guard::UI.error "[guard-i18n-js] #{message}"
    end

    def info(message)
      ::Guard::UI.info "[guard-i18n-js] #{message}"
    end
  end
end
