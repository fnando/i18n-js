# frozen_string_literal: true

require "i18n"
require "json"
require "yaml"
require "glob"
require "fileutils"
require "optparse"
require "erb"
require "digest/md5"
require "concurrent-ruby"

require_relative "i18n-js/schema"
require_relative "i18n-js/version"
require_relative "i18n-js/plugin"
require_relative "i18n-js/sort_hash"
require_relative "i18n-js/clean_hash"

module I18nJS
  MissingConfigError = Class.new(StandardError)

  def self.call(config_file: nil, config: nil, parallel: false)
    if !config_file && !config
      raise MissingConfigError,
            "you must set either `config_file` or `config`"
    end

    config = Glob::SymbolizeKeys.call(config || load_config_file(config_file))

    load_plugins!
    initialize_plugins!(config:)
    Schema.validate!(config)

    exported_files = []

    config[:translations].each do |group|
      exported_files += export_group(group, parallel:)
    end

    plugins.each do |plugin|
      plugin.after_export(files: exported_files.dup) if plugin.enabled?
    end

    exported_files
  end

  def self.export_group(group, parallel: false)
    filtered_translations = Glob.filter(translations, group[:patterns])
    filtered_translations =
      plugins.reduce(filtered_translations) do |buffer, plugin|
        if plugin.enabled?
          plugin.transform(translations: buffer)
        else
          buffer
        end
      end

    filtered_translations = sort_hash(clean_hash(filtered_translations))
    output_file_path = File.expand_path(group[:file])
    exported_files = []

    if output_file_path.include?(":locale")
      if parallel
        promises = []
        filtered_translations.each_key do |locale|
          promises <<
            Concurrent::Promises.future(
              output_file_path.gsub(":locale", locale.to_s),
              locale => filtered_translations[locale]
            ) do |locale_file_path, translations|
              write_file(locale_file_path, translations)
            end
        end
        exported_files = Concurrent::Promises.zip(*promises).value!
      else
        filtered_translations.each_key do |locale|
          locale_file_path = output_file_path.gsub(":locale", locale.to_s)
          exported_files << write_file(locale_file_path,
                                       locale => filtered_translations[locale])
        end
      end
    else
      exported_files << write_file(output_file_path, filtered_translations)
    end

    exported_files
  end

  def self.write_file(file_path, translations)
    FileUtils.mkdir_p(File.dirname(file_path))

    contents = ::JSON.pretty_generate(translations)
    digest = Digest::MD5.hexdigest(contents)
    file_path = file_path.gsub(":digest", digest)

    # Don't rewrite the file if it already exists and has the same content.
    # It helps the asset pipeline or webpack understand that file wasn't
    # changed.
    if File.exist?(file_path) && File.read(file_path) == contents
      return file_path
    end

    File.open(file_path, "w") do |file|
      file << contents
    end

    file_path
  end

  def self.translations
    ::I18n.backend.instance_eval do
      has_been_initialized_before =
        respond_to?(:initialized?, true) && initialized?
      init_translations unless has_been_initialized_before
      translations
    end
  end

  def self.load_config_file(config_file)
    erb = ERB.new(File.read(config_file))
    YAML.safe_load(erb.result(binding))
  end
end
