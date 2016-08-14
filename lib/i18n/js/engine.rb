require "i18n/js"

class I18nSprocketsExtension

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

module I18n
  module JS
    class Engine < ::Rails::Engine
      v2 = Gem::Dependency.new('', ' ~> 2')
      v3 = Gem::Dependency.new('', ' >= 3' ,' < 3.7')
      v37 = Gem::Dependency.new('', ' >= 3.7')

      sprockets_version = Gem::Version.new(Sprockets::VERSION).release

      initializer_args  = case sprockets_version
                          when -> (v) { v2.match?('', v) }
                            { after: "sprockets.environment" }
                          when -> (v) { v3.match?('', v) }
                            { after: :engines_blank_point, before: :finisher_hook }
                          when -> (v) { v37.match?('', v) }
                            { after: :engines_blank_point, before: :finisher_hook, silence_deprecation: true }
                          else
                            raise StandardError, "Sprockets version #{sprockets_version} is not supported"
                          end

      initializer 'i18n-js.register_preprocessor', initializer_args do
        next unless JS::Dependencies.using_asset_pipeline?
        next unless JS::Dependencies.sprockets_supports_register_preprocessor?

        Sprockets.register_preprocessor 'application/javascript', I18nSprocketsExtension
      end
    end
  end
end
