# frozen_string_literal: true

module I18nJS
  def self.clean_hash(hash)
    hash.keys.each_with_object({}) do |key, buffer|
      value = hash[key]

      next if value.is_a?(Proc)

      buffer[key] = value.is_a?(Hash) ? clean_hash(value) : value
    end
  end
end
