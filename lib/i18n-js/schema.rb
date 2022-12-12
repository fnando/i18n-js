# frozen_string_literal: true

module I18nJS
  class Schema
    InvalidError = Class.new(StandardError)

    REQUIRED_LINT_TRANSLATIONS_KEYS = %i[ignore].freeze
    REQUIRED_LINT_SCRIPTS_KEYS = %i[ignore patterns].freeze
    REQUIRED_TRANSLATION_KEYS = %i[file patterns].freeze
    TRANSLATION_KEYS = %i[file patterns].freeze

    def self.root_keys
      @root_keys ||= Set.new(%i[
        translations
        lint_translations
        lint_scripts
        check
      ])
    end

    def self.required_root_keys
      @required_root_keys ||= Set.new(%i[translations])
    end

    def self.validate!(target)
      schema = new(target)
      schema.validate!
      schema
    end

    attr_reader :target

    def initialize(target)
      @target = target
    end

    def validate!
      validate_root

      expect_required_keys(
        keys: self.class.required_root_keys,
        path: nil
      )

      reject_extraneous_keys(
        keys: self.class.root_keys,
        path: nil
      )

      validate_translations
      validate_lint_translations
      validate_lint_scripts
      validate_plugins
    end

    def validate_plugins
      I18nJS.plugins.each do |plugin|
        next unless target.key?(plugin.config_key)

        expect_type(
          path: [plugin.config_key, :enabled],
          types: [TrueClass, FalseClass]
        )

        plugin.validate_schema
      end
    end

    def validate_root
      return if target.is_a?(Hash)

      message =  "Expected config to be \"Hash\"; " \
                 "got #{target.class} instead"

      reject message, target
    end

    def validate_lint_translations
      key = :lint_translations

      return unless target.key?(key)

      expect_type(path: [key], types: Hash)

      expect_required_keys(
        keys: REQUIRED_LINT_TRANSLATIONS_KEYS,
        path: [key]
      )

      expect_type(path: [key, :ignore], types: Array)
    end

    def validate_lint_scripts
      key = :lint_scripts

      return unless target.key?(key)

      expect_type(path: [key], types: Hash)
      expect_required_keys(
        keys: REQUIRED_LINT_SCRIPTS_KEYS,
        path: [key]
      )
      expect_type(path: [key, :ignore], types: Array)
      expect_type(path: [key, :patterns], types: Array)
    end

    def validate_translations
      expect_array_with_items(path: [:translations])

      target[:translations].each_with_index do |translation, index|
        validate_translation(translation, index)
      end
    end

    def validate_translation(_translation, index)
      expect_required_keys(
        path: [:translations, index],
        keys: REQUIRED_TRANSLATION_KEYS
      )

      reject_extraneous_keys(
        keys: TRANSLATION_KEYS,
        path: [:translations, index]
      )

      expect_type(path: [:translations, index, :file], types: String)
      expect_array_with_items(path: [:translations, index, :patterns])
    end

    def reject(error_message, node = nil)
      node_json = "\n#{JSON.pretty_generate(node)}" if node
      raise InvalidError, "#{error_message}#{node_json}"
    end

    def expect_type(path:, types:)
      path = prepare_path(path: path)
      value = value_for(path: path)
      types = Array(types)

      return if types.any? {|type| value.is_a?(type) }

      actual_type = value.class

      type_desc = if types.size == 1
                    types[0].to_s.inspect
                  else
                    "one of #{types.inspect}"
                  end

      message = [
        "Expected #{path.join('.').inspect} to be #{type_desc};",
        "got #{actual_type} instead"
      ].join(" ")

      reject message, target
    end

    def expect_array_with_items(path:)
      expect_type(path: path, types: Array)

      path = prepare_path(path: path)
      value = value_for(path: path)

      return unless value.empty?

      reject "Expected #{path.join('.').inspect} to have at least one item",
             target
    end

    def expect_required_keys(keys:, path:)
      path = prepare_path(path: path)
      value = value_for(path: path)
      actual_keys = value.keys.map(&:to_sym)

      keys.each do |key|
        next if actual_keys.include?(key)

        path_desc = if path.empty?
                      key.to_s.inspect
                    else
                      (path + [key]).join(".").inspect
                    end

        reject "Expected #{path_desc} to be defined", target
      end
    end

    def reject_extraneous_keys(keys:, path:)
      path = prepare_path(path: path)
      value = value_for(path: path)

      actual_keys = value.keys.map(&:to_sym)
      extraneous = actual_keys.to_a - keys.to_a

      return if extraneous.empty?

      path_desc = if path.empty?
                    "config"
                  else
                    path.join(".").inspect
                  end

      reject "#{path_desc} has unexpected keys: #{extraneous.inspect}",
             target
    end

    def prepare_path(path:)
      path = path.to_s.split(".").map(&:to_sym) unless path.is_a?(Array)
      path
    end

    def value_for(path:)
      path.empty? ? target : target.dig(*path)
    end
  end
end
