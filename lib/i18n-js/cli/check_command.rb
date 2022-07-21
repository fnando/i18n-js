# frozen_string_literal: true

require "benchmark"

module I18nJS
  class CLI
    class CheckCommand < Command
      command_name "check"
      description "Check for missing translations"

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

        load_require_file!(require_file) if require_file
        default_locale = I18n.default_locale
        available_locales = I18n.available_locales

        mapping = available_locales.each_with_object({}) do |locale, buffer|
          buffer[locale] =
            Glob::Map.call(Glob.filter(I18nJS.translations, ["#{locale}.*"]))
                     .map {|key| key.gsub(/^.*?\./, "") }
        end

        default_locale_keys = mapping.delete(default_locale)

        ui.stdout_print "=> #{default_locale}: #{default_locale_keys.size} " \
                        "translations"

        total_missing_count = 0

        mapping.each do |locale, partial_keys|
          extraneous = partial_keys - default_locale_keys
          missing = default_locale_keys - (partial_keys - extraneous)
          total_missing_count += missing.size
          ui.stdout_print "=> #{locale}: #{missing.size} missing, " \
                          "#{extraneous.size} extraneous"

          all_keys = (default_locale_keys + extraneous + missing).uniq.sort

          all_keys.each do |key|
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
