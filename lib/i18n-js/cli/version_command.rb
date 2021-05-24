# frozen_string_literal: true

module I18nJS
  class CLI
    class VersionCommand < Command
      command_name "version"
      description "Show package version"

      parse do |opts|
        opts.banner = "Usage: i18n #{name}"

        opts.on_tail do
          ui.exit_with("v#{I18nJS::VERSION}")
        end
      end
    end
  end
end
