# frozen_string_literal: true

module I18nJS
  class CLI
    class Command
      attr_reader :ui, :argv

      def self.command_name(name)
        define_method(:name) { name }
      end

      def self.description(description)
        define_method(:description) { description }
      end

      def self.parse(&block)
        define_method(:parse) do
          OptionParser
            .new {|opts| instance_exec(opts, &block) }
            .parse!(argv)
        end
      end

      def self.command(&block)
        define_method(:command, &block)
      end

      def initialize(argv:, ui:)
        @argv = argv.dup
        @ui = ui
      end

      def call
        parse
        command
      end

      def options
        @options ||= {}
      end

      private def load_config_file(config_file)
        config = Glob::SymbolizeKeys.call(YAML.load_file(config_file))

        if config.key?(:check)
          config[:lint_translations] ||= config.delete(:check)
        end

        config
      end

      private def load_require_file!(require_file)
        require_without_warnings(require_file)
      rescue Exception => error # rubocop:disable Lint/RescueException
        ui.stderr_print("=> ERROR: couldn't load",
                        options[:require_file].inspect)
        ui.fail_with(
          "\n#{error_description(error)}\n#{error.backtrace.join("\n")}"
        )
      end

      private def error_description(error)
        [
          error.class.name,
          error.message
        ].reject(&:empty?).join(" => ")
      end

      private def require_without_warnings(path)
        old_verbose = $VERBOSE
        $VERBOSE = nil

        load path
      ensure
        $VERBOSE = old_verbose
      end
    end
  end
end
