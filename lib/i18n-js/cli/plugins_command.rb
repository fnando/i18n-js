# frozen_string_literal: true

module I18nJS
  class CLI
    class PluginsCommand < Command
      command_name "plugins"
      description "List plugins that will be activated"

      parse do |opts|
        opts.banner = "Usage: i18n #{name} [options]"

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
        ui.colored = options[:colored]

        if options[:require_file]
          ui.stdout_print("=> Require file:", options[:require_file].inspect)
          require_file = File.expand_path(options[:require_file])
        end

        if require_file && !File.file?(require_file)
          ui.fail_with(
            "=> ERROR: require file doesn't exist at",
            require_file.inspect
          )
        end

        load_require_file!(require_file) if require_file

        files = I18nJS.plugin_files

        if files.empty?
          ui.stdout_print("=> No plugins have been detected.")
        else
          ui.stdout_print("=> Plugins that will be activated:")

          files.each do |file|
            file = file.gsub("#{Dir.home}/", "~/")

            ui.stdout_print("   * #{file}")
          end
        end
      end

      private def set_defaults!
        config_file = "./config/i18n.yml"
        require_file = "./config/environment.rb"

        options[:config_file] ||= config_file if File.file?(config_file)
        options[:require_file] ||= require_file if File.file?(require_file)
      end
    end
  end
end
