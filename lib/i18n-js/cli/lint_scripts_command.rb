# frozen_string_literal: true

module I18nJS
  class CLI
    class LintScriptsCommand < Command
      command_name "lint:scripts"
      description "Lint files using TypeScript"

      parse do |opts|
        opts.banner = "Usage: i18n #{name} [options]"

        opts.on(
          "-cCONFIG_FILE",
          "--config=CONFIG_FILE",
          "The configuration file that will be used"
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

        opts.on(
          "-nNODE_PATH",
          "--node-path=NODE_PATH",
          "Set node.js path"
        ) do |node_path|
          options[:node_path] = node_path
        end

        opts.on("-h", "--help", "Prints this help") do
          ui.exit_with opts.to_s
        end
      end

      command do
        set_defaults!
        ui.colored = options[:colored]

        unless options[:config_file]
          ui.fail_with("=> ERROR: you need to specify the config file")
        end

        ui.stdout_print("=> Config file:", options[:config_file].inspect)
        config_file = File.expand_path(options[:config_file])

        if options[:require_file]
          ui.stdout_print("=> Require file:", options[:require_file].inspect)
          require_file = File.expand_path(options[:require_file])
        end

        node_path = options[:node_path] || find_node
        ui.stdout_print("=> Node:", node_path.inspect)

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

        found_node = node_path && File.executable?(File.expand_path(node_path))

        unless found_node
          ui.fail_with(
            "=> ERROR: node.js couldn't be found (path: #{node_path})"
          )
        end

        config = load_config_file(config_file)
        I18nJS.load_plugins!
        I18nJS.initialize_plugins!(config: config)
        Schema.validate!(config)

        load_require_file!(require_file) if require_file

        available_locales = I18n.available_locales
        ignored_keys = config.dig(:lint_scripts, :ignore) || []

        ui.stdout_print "=> Available locales: #{available_locales.inspect}"

        exported_files = I18nJS.call(config_file: config_file)
        data = exported_files.each_with_object({}) do |file, buffer|
          buffer.merge!(JSON.load_file(file, symbolize_names: true))
        end

        lint_file = File.expand_path(File.join(__dir__, "../lint.js"))
        patterns = config.dig(:lint_scripts, :patterns) || %w[
          !(node_modules)/**/*.js
          !(node_modules)/**/*.ts
          !(node_modules)/**/*.jsx
          !(node_modules)/**/*.tsx
        ]

        ui.stdout_print "=> Patterns: #{patterns.inspect}"

        out = IO.popen([node_path, lint_file, patterns.join(":")]).read
        scopes = JSON.parse(out, symbolize_names: true)
        map = Glob::Map.call(data)
        missing_count = 0
        ignored_count = 0

        messages = []

        available_locales.each do |locale|
          scopes.each do |scope|
            scope_with_locale = "#{locale}.#{scope[:full]}"

            ignored = ignored_keys.include?(scope[:full]) ||
                      ignored_keys.include?(scope_with_locale)

            if ignored
              ignored_count += 1
              next
            end

            next if map.include?(scope_with_locale)

            missing_count += 1
            messages << "   - #{scope[:location]}: #{scope_with_locale}"
          end
        end

        ui.stdout_print "=> #{map.size} translations, #{missing_count} " \
                        "missing, #{ignored_count} ignored"
        ui.stdout_print messages.sort.join("\n")

        exit(missing_count.size)
      end

      private def set_defaults!
        config_file = "./config/i18n.yml"
        require_file = "./config/environment.rb"

        options[:config_file] ||= config_file if File.file?(config_file)
        options[:require_file] ||= require_file if File.file?(require_file)
      end

      private def find_node
        ENV["PATH"]
          .split(File::PATH_SEPARATOR)
          .map {|dir| File.join(dir, "node") }
          .find {|bin| File.executable?(bin) }
      end
    end
  end
end
