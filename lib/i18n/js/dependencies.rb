module I18n
  module JS
    module Dependencies
      class << self
        def rails3?
          safe_gem_check("rails", "~> 3") && running_rails3?
        end

        def rails4?
          safe_gem_check("rails", "~> 4") && running_rails4?
        end

        def rails?
          rails_available? && running_rails?
        end

        def rails_available?
          safe_gem_check("rails", '>= 3')
        end

        def using_asset_pipeline?
          assets_pipeline_available =
            (rails3? || rails4?) &&
            Rails.respond_to?(:application) &&
            Rails.application.respond_to?(:assets)
          rails3_assets_enabled =
            rails3? &&
            assets_pipeline_available &&
            Rails.application.config.assets.enabled != false

          assets_pipeline_available && (rails4? || rails3_assets_enabled)
        end

        private

        def running_rails3?
          running_rails? && Rails.version.to_i == 3
        end

        def running_rails4?
          running_rails? && Rails.version.to_i == 4
        end

        def running_rails?
          defined?(Rails) && Rails.respond_to?(:version)
        end

        def safe_gem_check(gem_name, version_string)
          if Gem::Specification.respond_to?(:find_by_name)
            Gem::Specification.find_by_name(gem_name, version_string)
          elsif Gem.respond_to?(:available?)
            Gem.available?(gem_name, version_string)
          end
        rescue Gem::LoadError
          false
        end

      end
    end
  end
end
