# frozen_string_literal: true

module I18nJS
  class CLI
    class UI
      attr_reader :stdout, :stderr
      attr_accessor :colored

      def initialize(stdout:, stderr:, colored: nil)
        @stdout = stdout
        @stderr = stderr
        @colored = colored
      end

      def stdout_print(*message)
        stdout << "#{message.join(' ')}\n"
      end

      def stderr_print(*message)
        stderr << "#{message.join(' ')}\n"
      end

      def fail_with(*message)
        stderr_print(message)
        exit(1)
      end

      def exit_with(*message)
        stdout_print(message)
        exit(0)
      end

      def yellow(text)
        ansi(text, 33)
      end

      def red(text)
        ansi(text, 31)
      end

      def colored?
        colored_output = if colored.nil?
                           stdout.tty?
                         else
                           colored
                         end

        colored_output && !no_color?
      end

      def ansi(text, code)
        if colored?
          "\e[#{code}m#{text}\e[0m"
        else
          text
        end
      end

      def no_color?
        !ENV["NO_COLOR"].nil? && ENV["NO_COLOR"] == "1"
      end
    end
  end
end
