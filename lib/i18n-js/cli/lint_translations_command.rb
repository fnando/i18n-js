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
        I18nJS.initialize_plugins!(config: config)
        Schema.validate!(config)

        load_require_file!(require_file) if require_file

        default_locale = I18n.default_locale
        available_locales = I18n.available_locales
        ignored_keys = config.dig(:lint_translations, :ignore) || []

        mapping = available_locales.each_with_object({}) do |locale, buffer|
          buffer[locale] =
            Glob::Map.call(Glob.filter(I18nJS.translations, ["#{locale}.*"]))
                     .map {|key| key.gsub(/^.*?\./, "") }
        end

        default_locale_keys = mapping.delete(default_locale) || mapping

        if ignored_keys.any?
          ui.stdout_print "=> Check #{options[:config_file].inspect} for " \
                          "ignored keys."
        end

        ui.stdout_print "=> #{default_locale}: #{default_locale_keys.size} " \
                        "translations"

        total_missing_count = 0

        mapping.each do |locale, partial_keys|
          ignored_count = 0

          # Compute list of filtered keys (i.e. keys not ignored)
          filtered_keys = partial_keys.reject do |key|
            key = "#{locale}.#{key}"

            ignored = ignored_keys.include?(key)
            ignored_count += 1 if ignored
            ignored
          end

          extraneous = (partial_keys - default_locale_keys).reject do |key|
            key = "#{locale}.#{key}"
            ignored = ignored_keys.include?(key)
            ignored_count += 1 if ignored
            ignored
          end

          missing = (default_locale_keys - (filtered_keys - extraneous))
                    .reject {|key| ignored_keys.include?("#{locale}.#{key}") }

          ignored_count += extraneous.size
          total_missing_count += missing.size

          ui.stdout_print "=> #{locale}: #{missing.size} missing, " \
                          "#{extraneous.size} extraneous, " \
                          "#{ignored_count} ignored"

          all_keys = (default_locale_keys + extraneous + missing).uniq.sort

          all_keys.each do |key|
            next if ignored_keys.include?("#{locale}.#{key}")

            label = if extraneous.include?(key)
                      ui.yellow("extraneous")
                    elsif missing.include?(key)
                      ui.red("missing")
                    else
                      next
                    end

            ui.stdout_print("   - #{locale}.#{key} (#{label})")
          end
        end

        exit(1) if total_missing_count.nonzero?
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
