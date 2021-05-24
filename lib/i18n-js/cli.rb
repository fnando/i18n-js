# frozen_string_literal: true

module I18nJS
  class CLI
    attr_reader :ui

    def initialize(argv:, stdout:, stderr:)
      @argv = argv.dup
      @ui = UI.new(stdout: stdout, stderr: stderr)
    end

    def call
      command_name = @argv.shift
      command = commands.find {|cmd| cmd.name == command_name }

      ui.fail_with(root_help) unless command

      command.call
    end

    private def command_classes
      [InitCommand, ExportCommand, VersionCommand]
    end

    private def commands
      command_classes.map do |command_class|
        command_class.new(argv: @argv, ui: ui)
      end
    end

    private def root_help
      commands_list = commands
                      .map {|cmd| "- #{cmd.name}: #{cmd.description}" }
                      .join("\n")

      <<~TEXT
        Usage: i18n COMMAND FLAGS

        Commands:

        #{commands_list}

        Run `i18n COMMAND --help` for more information on specific commands.
      TEXT
    end
  end
end
