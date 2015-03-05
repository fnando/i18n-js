module I18n
  module JS
    module Utils
      # deep_merge by Stefan Rusterholz, see <http://www.ruby-forum.com/topic/142809>.
      MERGER = proc do |key, v1, v2|
        Hash === v1 && Hash === v2 ? v1.merge(v2, &MERGER) : v2
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

      def self.deep_reject(hash, &block)
        hash.each_with_object({}) do |(k, v), memo|
          unless block.call(k, v)
            memo[k] = v.kind_of?(Hash) ? deep_reject(v, &block) : v
          end
        end
      end
    end
  end
end
