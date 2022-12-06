# frozen_string_literal: true

module I18nJS
  class Schema
    InvalidError = Class.new(StandardError)

    REQUIRED_CHECK_KEYS = %i[ignore].freeze
    REQUIRED_TRANSLATION_KEYS = %i[file patterns].freeze
    TRANSLATION_KEYS = %i[file patterns].freeze

    def self.root_keys
      @root_keys ||= Set.new(%i[translations check])
    end

    def self.required_root_keys
      @required_root_keys ||= Set.new(%i[translations])
    end

    def self.validate!(target)
      schema = new(target)
      schema.validate!
      I18nJS.plugins.each {|plugin| plugin.validate_schema(config: target) }
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
      validate_check
    end

    def validate_check
      return unless target.key?(:check)

      check = target[:check]

      expect_type(:check, check, Hash, target)
      expect_required_keys(REQUIRED_CHECK_KEYS, check)
      expect_type(:ignore, check[:ignore], Array, check)
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

    def expect_enabled_config(config_key, value)
      return if [TrueClass, FalseClass].include?(value.class)

      actual_type = value.class

      reject "Expected #{config_key}.enabled to be a boolean; " \
             "got #{actual_type} instead"
    end

    def expect_type(attribute, value, expected_type, payload)
      return if value.is_a?(expected_type)

      actual_type = value.class

      message = [
        "Expected #{attribute.inspect} to be #{expected_type};",
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
