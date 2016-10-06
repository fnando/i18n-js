module I18n
  module JS
    # When using `safe_gem_check` to check for a pre-release version of gem,
    # we need to specify pre-release version suffix in version constraint
    module Dependencies
      class << self
        def rails3?
          safe_gem_check("rails", "~> 3.0") && running_rails3?
        end

        def rails4?
          safe_gem_check("rails", "~> 4.0", ">= 4.0.0.beta1") && running_rails4?
        end

        def rails5?
          safe_gem_check("rails", "~> 5.0", ">= 5.0.0.beta1") && running_rails5?
        end

        def sprockets_supports_register_preprocessor?
          defined?(Sprockets) && Sprockets.respond_to?(:register_preprocessor)
        end

        def rails?
          rails_available? && running_rails?
        end

        def rails_available?
          safe_gem_check("rails", '>= 3.0.0.beta')
        end

        # This cannot be called at class definition time
        # Since not all libraries are loaded
        #
        # Call this in an initializer
        def using_asset_pipeline?
          assets_pipeline_available =
            (rails3? || rails4? || rails5?) &&
            Rails.respond_to?(:application) &&
            Rails.application.respond_to?(:assets)
          rails3_assets_enabled =
            rails3? &&
            assets_pipeline_available &&
            Rails.application.config.assets.enabled != false

          assets_pipeline_available && (rails4? || rails5? || rails3_assets_enabled)
        end

        private

        def running_rails3?
          running_rails? && Rails.version.to_i == 3
        end

        def running_rails4?
          running_rails? && Rails.version.to_i == 4
        end

        def running_rails5?
          running_rails? && Rails.version.to_i == 5
        end

        def running_rails?
          defined?(Rails) && Rails.respond_to?(:version)
        end

        def safe_gem_check(*args)
          if Gem::Specification.respond_to?(:find_by_name)
            Gem::Specification.find_by_name(*args)
          elsif Gem.respond_to?(:available?)
            Gem.available?(*args)
          end
        rescue Gem::LoadError
          false
        end

      end
    end
  end
end
