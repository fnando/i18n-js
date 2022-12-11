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
      I18nJS.plugins.each do |plugin|
        next unless target.key?(plugin.config_key)

        schema.expect_type(
          :enabled,
          plugin.config[:enabled],
          [TrueClass, FalseClass],
          {plugin.config_key => plugin.config}
        )

        plugin.validate_schema
      end
    end

    attr_reader :target

    def initialize(target)
      @target = target
    end

    def validate!
      expect_type(:root, target, Hash, target)

      expect_required_keys(self.class.required_root_keys, target)
      reject_extraneous_keys(self.class.root_keys, target)
      validate_translations
      validate_lint_translations
      validate_lint_scripts
    end

    def validate_lint_translations
      key = :lint_translations

      return unless target.key?(key)

      config = target[key]

      expect_type(key, config, Hash, target)
      expect_required_keys(REQUIRED_LINT_TRANSLATIONS_KEYS, config)
      expect_type(:ignore, config[:ignore], Array, config)
    end

    def validate_lint_scripts
      key = :lint_scripts

      return unless target.key?(key)

      config = target[key]

      expect_type(key, config, Hash, target)
      expect_required_keys(REQUIRED_LINT_SCRIPTS_KEYS, config)
      expect_type(:ignore, config[:ignore], Array, config)
      expect_type(:patterns, config[:patterns], Array, config)
    end

    def validate_translations
      translations = target[:translations]

      expect_type(:translations, translations, Array, target)
      expect_array_with_items(:translations, translations)

      translations.each do |translation|
        validate_translation(translation)
      end
    end

    def validate_translation(translation)
      expect_required_keys(REQUIRED_TRANSLATION_KEYS, translation)
      reject_extraneous_keys(TRANSLATION_KEYS, translation)
      expect_type(:file, translation[:file], String, translation)
      expect_type(:patterns, translation[:patterns], Array, translation)
      expect_array_with_items(:patterns, translation[:patterns], translation)
    end

    def reject(error_message, node = nil)
      node_json = "\n#{JSON.pretty_generate(node)}" if node
      raise InvalidError, "#{error_message}#{node_json}"
    end

    def expect_type(attribute, value, expected_type, payload)
      expected_type = Array(expected_type)

      return if expected_type.any? {|klass| value.is_a?(klass) }

      actual_type = value.class

      message = [
        "Expected #{attribute.inspect} to be one of #{expected_type};",
        "got #{actual_type} instead"
      ].join(" ")

      reject message, payload
    end

    def expect_array_with_items(attribute, value, payload = value)
      return unless value.empty?

      reject "Expected #{attribute.inspect} to have at least one item", payload
    end

    def expect_required_keys(required_keys, value)
      keys = value.keys.map(&:to_sym)

      required_keys.each do |key|
        next if keys.include?(key)

        reject "Expected #{key.inspect} to be defined", value
      end
    end

    def reject_extraneous_keys(allowed_keys, value)
      keys = value.keys.map(&:to_sym)
      extraneous = keys.to_a - allowed_keys.to_a

      return if extraneous.empty?

      reject "Unexpected keys: #{extraneous.join(', ')}", value
    end
  end
end
