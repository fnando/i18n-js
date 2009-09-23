module SimplesIdeias
  module I18n
    extend self
    
    JAVASCRIPT_DIR = File.join(Rails.root, "public", "javascripts")
    
    def export!
      ::I18n.backend.__send__ :init_translations
      File.open(JAVASCRIPT_DIR + "/messages.js", "w+") do |f|
        f << %(var I18n = I18n || {};\n)
        f << %(I18n.translations = );
        f << ::I18n.backend.__send__(:translations).to_json
        f << %(;)
      end
    end
    
    def copy!
      File.open(JAVASCRIPT_DIR + "/i18n.js", "w+") do |f| 
        f << File.read(File.dirname(__FILE__) + "/i18n.js")
      end
    end
  end
end
