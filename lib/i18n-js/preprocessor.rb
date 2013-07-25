module SimplesIdeias
  module I18n
    class Preprocessor < ::Sprockets::Processor
      def evaluate(context, locals)
        if context.logical_path == Engine::I18N_TRANSLATIONS_ASSET
          cache_file = I18n::Engine.load_path_hash_cache
          config = I18n.config_file

          context.depend_on(config) if I18n.config?
          # also set up dependencies on every locale file
          ::I18n.load_path.each {|path| context.depend_on(path)}

          # Set up a dependency on the contents of the load path
          # itself. In some situations it is possible to get here
          # before the path hash cache file has been written; in
          # this situation, write it now.
          I18n::Engine.write_hash! unless File.exists?(cache_file)
          context.depend_on(cache_file)
        end

        data
      end
    end
  end
end
