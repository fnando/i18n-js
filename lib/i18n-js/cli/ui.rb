# frozen_string_literal: true

module I18nJS
  class CLI
    class UI
      def initialize(stdout:, stderr:)
        @stdout = stdout
        @stderr = stderr
      end

      def stdout_print(*message)
        @stdout << "#{message.join(' ')}\n"
      end

      def stderr_print(*message)
        @stderr << "#{message.join(' ')}\n"
      end

      def fail_with(*message)
        stderr_print(message)
        exit(1)
      end

      def exit_with(*message)
        stdout_print(message)
        exit(0)
      end
    end
  end
end
