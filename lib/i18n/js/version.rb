module I18n
  module JS
    module Version
      MAJOR = 3
      MINOR = 0
      TINY  = 0
      PATCH = "rc3" # Could be nil
      
      STRING = [MAJOR, MINOR, TINY, PATCH].compact.join('.')
    end
  end
end
