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
    end
  end
end
