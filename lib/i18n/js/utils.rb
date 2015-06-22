module I18n
  module JS
    module Utils
      # deep_merge by Stefan Rusterholz, see <http://www.ruby-forum.com/topic/142809>.
      # The last result is modified to treat `nil` as missing key
      MERGER = proc do |_key, v1, v2|
        Hash === v1 && Hash === v2 ? v1.merge(v2, &MERGER) : (v2.nil? ? v1 : v2)
      end

      HASH_NIL_VALUE_CLEANER_PROC = proc do |k, v|
        v.kind_of?(Hash) ? (v.delete_if(&HASH_NIL_VALUE_CLEANER_PROC); false) : v.nil?
      end

      def self.strip_keys_with_nil_values(hash)
        hash.dup.delete_if(&HASH_NIL_VALUE_CLEANER_PROC)
      end

      def self.deep_merge(target_hash, hash) # :nodoc:
        target_hash.merge(hash, &MERGER)
      end

      def self.deep_merge!(target_hash, hash) # :nodoc:
        target_hash.merge!(hash, &MERGER)
      end

      def self.deep_reject(hash, scopes = [], &block)
        hash.each_with_object({}) do |(k, v), memo|
          unless block.call(k, v, scopes + [k.to_s])
            memo[k] = v.kind_of?(Hash) ? deep_reject(v, scopes + [k.to_s], &block) : v
          end
        end
      end

      def self.scopes_match?(scopes1, scopes2)
        if scopes1.length == scopes2.length
          [scopes1, scopes2].transpose.all? do |scope1, scope2|
            scope1.to_s == '*' || scope2.to_s == '*' || scope1.to_s == scope2.to_s
          end
        end
      end

      def self.deep_key_sort(hash)
        # Avoid things like `true` or `1` from YAML which causes error
        hash.keys.sort {|a, b| a.to_s <=> b.to_s}.
          each_with_object({}) do |key, seed|
          value = hash[key]
          seed[key] = value.is_a?(Hash) ? deep_key_sort(value) : value
        end
      end
    end
  end
end
