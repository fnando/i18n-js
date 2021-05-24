# frozen_string_literal: true

gem "listen"
require "listen"
require "i18n-js"

module I18nJS
  class << self
    attr_accessor :started
  end

  def self.listen(
    config_file: Rails.root.join("config/i18n.yml"),
    locales_dir: Rails.root.join("config/locales")
  )
    return unless Rails.env.development?
    return if started

    self.started = true

    relative_paths =
      [config_file, locales_dir].map {|path| relative_path(path) }

    debug("Watching #{relative_paths.inspect}")

    listener(config_file, locales_dir.to_s).start
    I18nJS.call(config_file: config_file)
  end

  def self.relative_path(path)
    Pathname.new(path).relative_path_from(Rails.root).to_s
  end

  def self.relative_path_list(paths)
    paths.map {|path| relative_path(path) }
  end

  def self.debug(message)
    logger.tagged("i18n-js") { logger.debug(message) }
  end

  def self.logger
    @logger ||= ActiveSupport::TaggedLogging.new(Rails.logger)
  end

  def self.listener(config_file, locales_dir) # rubocop:disable Metrics/MethodLength
    paths = [File.dirname(config_file), locales_dir]

    Listen.to(*paths) do |changed, added, removed|
      changes = compute_changes(
        [config_file, locales_dir],
        changed,
        added,
        removed
      )

      next unless changes.any?

      debug(changes.map {|key, value| "#{key}=#{value.inspect}" }.join(", "))

      I18nJS.call(config_file: config_file)
    end
  end

  def self.compute_changes(paths, changed, added, removed)
    paths = paths.map {|path| relative_path(path) }

    {
      changed: included_on_watched_paths(paths, changed),
      added: included_on_watched_paths(paths, added),
      removed: included_on_watched_paths(paths, removed)
    }.select {|_k, v| v.any? }
  end

  def self.included_on_watched_paths(paths, changes)
    changes.map {|change| relative_path(change) }.select do |change|
      paths.any? {|path| change.start_with?(path) }
    end
  end
end
