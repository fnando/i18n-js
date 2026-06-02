# frozen_string_literal: true

module I18nJS
  class CLI
    class LintTranslationsCommand < Command
      command_name "lint:translations"
      description "Check for missing translations based on the default locale"

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
          "--[no-]color",
          "Force colored output"
        ) do |colored|
          options[:colored] = colored
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

        config = load_config_file(config_file)
        I18nJS.load_plugins!
        Schema.validate!(config)
        I18nJS.initialize_plugins!(config)

        load_require_file!(require_file) if require_file

        default_locale = I18n.default_locale
        available_locales = I18n.available_locales
                                .reject {|locale| locale == default_locale }
        ignore_matchers =
          (config.dig(:lint_translations, :ignore) || []).map do |path|
            Glob::Matcher.new(path)
          end

        default_keys = build_locale_keys(default_locale)

        ui.stdout_print "=> #{default_locale}: #{default_keys.size} " \
                        "translations"

        missing_count = 0

        available_locales.each do |locale|
          source_keys = default_keys
                        .reject do |key|
            ignored?(
              ignore_matchers, "#{locale}.#{key}"
            )
          end
          ignored_count = default_keys.size - source_keys.size

          locale_keys = build_locale_keys(locale)
          ignored = locale_keys.select do |key|
            ignored?(ignore_matchers, "#{locale}.#{key}")
          end

          ignored_count += ignored.size
          source_keys -= ignored
          missing = source_keys - locale_keys
          extraneous = locale_keys - source_keys - ignored

          missing_count += missing.size

          ui.stdout_print "=> #{locale}: #{missing.size} missing, " \
                          "#{extraneous.size} extraneous, " \
                          "#{ignored_count} ignored"

          all_keys =
            (
              build_list_with_label(missing, :missing) +
              build_list_with_label(extraneous, :extraneous)
            ).sort_by(&:first)

          all_keys.each do |key, label|
            label = if label == :extraneous
                      ui.yellow("extraneous")
                    else
                      ui.red("missing")
                    end

            ui.stdout_print("   - #{locale}.#{key} (#{label})")
          end
        end

        exit(missing_count)
      end

      def build_list_with_label(list, label)
        list.map {|item| [item, label] }
      end

      def ignored?(matchers, key)
        matchers.any? {|matcher| matcher.match?(key) }
      end

      private def build_locale_keys(locale)
        Glob::Map
          .call(Glob.filter(I18nJS.translations, ["#{locale}.*"]))
          .map {|key| strip_locale(key) }
      end

      private def strip_locale(key)
        key.gsub(/^.*?\./, "")
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
