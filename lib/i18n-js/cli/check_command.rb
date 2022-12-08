# frozen_string_literal: true

module I18nJS
  class CLI
    class CheckCommand < LintTranslationsCommand
      command_name "check"
      description "Check for missing translations based on the default " \
                  "locale (DEPRECATED: Use `i18n lint:translations` instead)"

      def command
        ui.stderr_print "=> WARNING: `i18n check` has been deprecated in " \
                        "favor of `i18n lint:translations`"
        super
      end
    end
  end
end
