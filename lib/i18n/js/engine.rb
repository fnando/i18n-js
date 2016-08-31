require "i18n/js"

module I18n
  module JS
    # @api private
    # The class cannot be private
    class SprocketsExtension
      # Actual definition is placed below
    end

    class Engine < ::Rails::Engine
      if JS::Dependencies.sprockets_supports_register_preprocessor?
        # constant `Sprockets` should be available here after
        # `.sprockets_supports_register_preprocessor?` called
        sprockets_version = Gem::Version.new(Sprockets::VERSION).release
        v2_only = Gem::Dependency.new("", " ~> 2")
        v3_plus = Gem::Dependency.new("", " >= 3")

        # See https://github.com/rails/sprockets/blob/master/guides/extending_sprockets.md#supporting-all-versions-of-sprockets-in-processors
        # for reference of supporting multiple versions

        # `sprockets.environment` was used for 1.x of `sprockets-rails`
        # https://github.com/rails/sprockets-rails/issues/227
        #
        # References for current values:
        #
        # Here is where sprockets are attached with Rails. There is no 'sprockets.environment' mentioned.
        # https://github.com/rails/sprockets-rails/blob/master/lib/sprockets/railtie.rb
        #
        # Finisher hook is the place which should be used as border.
        # http://guides.rubyonrails.org/configuring.html#initializers
        #
        # For detail see Pull Request:
        # https://github.com/fnando/i18n-js/pull/371
        #
        # Not using -> for JRuby compatibility
        # See https://github.com/fnando/i18n-js/issues/419
        initializer_args = case sprockets_version
        when lambda {|v| v2_only.match?("", v) || v3_plus.match?("", v) }
          { after: :engines_blank_point, before: :finisher_hook }
        else
          raise StandardError, "Sprockets version #{sprockets_version} is not supported"
        end

        initializer "i18n-js.register_preprocessor", initializer_args do
          # This must be called inside initializer block
          # For details see comments for `using_asset_pipeline?`
          next unless JS::Dependencies.using_asset_pipeline?

          # From README of 2.x & 3.x of `sprockets-rails`
          # It seems the `configure` block is preferred way to call `register_preprocessor`
          # Not sure if this will break older versions of rails
          #
          # https://github.com/rails/sprockets-rails/blob/v2.3.3/README.md
          # https://github.com/rails/sprockets-rails/blob/v3.0.0/README.md
          Rails.application.config.assets.configure do |config|
            config.register_preprocessor(
              "application/javascript",
              ::I18n::JS::SprocketsExtension,
            )
          end
        end
      end
    end

    # @api private
    class SprocketsExtension
      def initialize(filename, &block)
        @filename = filename
        @source   = block.call
      end

      def render(context, empty_hash_wtf)
        self.class.run(@filename, @source, context)
      end

      def self.run(filename, source, context)
        if context.logical_path == "i18n/filtered"
          ::I18n.load_path.each { |path| context.depend_on(File.expand_path(path)) }
        end

        source
      end

      def self.call(input)
        filename = input[:filename]
        source   = input[:data]
        context  = input[:environment].context_class.new(input)

        result = run(filename, source, context)
        context.metadata.merge(data: result)
      end
    end
  end
end
