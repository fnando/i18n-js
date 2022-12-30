# frozen_string_literal: true

module I18nJS
  def self.sort_hash(hash)
    return hash unless hash.is_a?(Hash)

    hash.keys.sort_by(&:to_s).each_with_object({}) do |key, seed|
      value = hash[key]
      seed[key] = value.is_a?(Hash) ? sort_hash(value) : value
    end
  end
end
