# frozen_string_literal: true

module I18nJS
  require "i18n-js/plugin"

  class EmbedFallbackTranslationsPlugin < I18nJS::Plugin
    module Utils
      # Based on deep_merge by Stefan Rusterholz, see
      # <https://www.ruby-forum.com/topic/142809>.
      # This method is used to handle I18n fallbacks. Given two equivalent path
      # nodes in two locale trees:
      # 1. If the node in the current locale appears to be an I18n pluralization
      #    (:one, :other, etc.), use the node, but merge in any missing/non-nil
      #    keys from the fallback (default) locale.
      # 2. Else if both nodes are Hashes, combine (merge) the key-value pairs of
      #    the two nodes into one, prioritizing the current locale.
      # 3. Else if either node is nil, use the other node.

      PLURAL_KEYS = %i[zero one two few many other].freeze
      PLURAL_MERGER = proc {|_key, v1, v2| v1 || v2 }
      MERGER = proc do |_key, v1, v2|
        if v1.is_a?(Hash) && v2.is_a?(Hash)
          if (v2.keys - PLURAL_KEYS).empty?
            v2.merge(v1, &PLURAL_MERGER).slice(*v2.keys)
          else
            v1.merge(v2, &MERGER)
          end
        else
          v2 || v1
        end
      end

      def self.deep_merge(target_hash, hash)
        target_hash.merge(hash, &MERGER)
      end
    end

    def setup
      I18nJS::Schema.root_keys << config_key
    end

    def validate_schema
      valid_keys = %i[enabled]

      schema.expect_required_keys(keys: valid_keys, path: [config_key])
      schema.reject_extraneous_keys(keys: valid_keys, path: [config_key])
    end

    def transform(translations:)
      return translations unless enabled?

      fallback_locale = I18n.default_locale.to_sym
      locales_to_fallback = translations.keys - [fallback_locale]

      translations_with_fallback = {}
      translations_with_fallback[fallback_locale] =
        translations[fallback_locale]

      locales_to_fallback.each do |locale|
        translations_with_fallback[locale] = Utils.deep_merge(
          translations[fallback_locale], translations[locale]
        )
      end

      translations_with_fallback
    end
  end

  I18nJS.register_plugin(EmbedFallbackTranslationsPlugin)
end
