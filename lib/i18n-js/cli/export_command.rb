# frozen_string_literal: true

require "benchmark"

module I18nJS
  class CLI
    class ExportCommand < Command
      command_name "export"
      description "Export translations as JSON files"

      parse do |opts|
        opts.banner = "Usage: i18n #{name} [options]"

        opts.on(
          "-cCONFIG_FILE",
          "--config=CONFIG_FILE",
          "The configuration file that will be generated"
        ) do |config_file|
          options[:config_file] = config_file
        end

        opts.on(
          "-rREQUIRE_FILE",
          "--require=REQUIRE_FILE",
          "A Ruby file that must be loaded"
        ) do |require_file|
          options[:require_file] = require_file
        end

        opts.on("-h", "--help", "Prints this help") do
          ui.exit_with opts.to_s
        end
      end

      command do
        set_defaults!

        ui.stdout_print("=> config file:", options[:config_file].inspect)
        ui.stdout_print("=> require file:", options[:require_file].inspect)

        unless options[:config_file]
          ui.fail_with("=> ERROR: you need to specify the config file")
        end

        config_file = File.expand_path(options[:config_file])

        if options[:require_file]
          require_file = File.expand_path(options[:require_file])
        end

        unless File.file?(config_file)
          ui.fail_with(
            "=> ERROR: config file doesn't exist at",
            config_file.inspect
          )
        end

        if require_file && !File.file?(require_file)
          ui.fail_with(
            "=> ERROR: require file doesn't exist at",
            require_file.inspect
          )
        end

        time = Benchmark.realtime do
          load_require_file!(require_file) if require_file
          I18nJS.call(config_file: config_file)
        end

        ui.stdout_print("=> done in #{time.round(2)}s")
      end

      private def set_defaults!
        config_file = "./config/i18n.yml"
        require_file = "./config/environment.rb"

        options[:config_file] ||= config_file if File.file?(config_file)
        options[:require_file] ||= require_file if File.file?(require_file)
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

        require path
      ensure
        $VERBOSE = old_verbose
      end
    end
  end
end
