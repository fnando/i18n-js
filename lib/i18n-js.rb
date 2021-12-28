# frozen_string_literal: true

require "i18n"
require "json"
require "yaml"
require "glob"
require "fileutils"
require "optparse"

require_relative "i18n-js/schema"
require_relative "i18n-js/version"

module I18nJS
  MissingConfigError = Class.new(StandardError)

  def self.call(config_file: nil, config: nil)
    if !config_file && !config
      raise MissingConfigError,
            "you must set either `config_file` or `config`"
    end

    config = Glob::SymbolizeKeys.call(config || YAML.load_file(config_file))
    Schema.validate!(config)

    config[:translations].each do |group|
      export_group(group)
    end
  end

  def self.export_group(group)
    filtered_translations = Glob.filter(translations, group[:patterns])
    output_file_path = File.expand_path(group[:file])

    if output_file_path.include?(":locale")
      filtered_translations.each_key do |locale|
        locale_file_path = output_file_path.gsub(/:locale/, locale.to_s)
        write_file(locale_file_path, locale => filtered_translations[locale])
      end
    else
      write_file(output_file_path, filtered_translations)
    end
  end

  def self.write_file(file_path, translations)
    FileUtils.mkdir_p(File.dirname(file_path))

    File.open(file_path, "w") do |file|
      file << ::JSON.pretty_generate(translations)
    end
  end

  def self.translations
    ::I18n.backend.instance_eval do
      has_been_initialized_before =
        respond_to?(:initialized?, true) && initialized?
      init_translations unless has_been_initialized_before
      translations
    end
  end
end
