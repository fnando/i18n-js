require 'test_helper'

class I18nJSTest < ActiveSupport::TestCase
  setup do
    `rm #{SimplesIdeias::I18n::JAVASCRIPT_DIR}/{messages,i18n}.js 2>&1 /dev/null`
  end
  
  teardown do
    `rm #{SimplesIdeias::I18n::JAVASCRIPT_DIR}/{messages,i18n}.js 2>&1 /dev/null`
  end
  
  test "copy i18n.js" do
    SimplesIdeias::I18n.copy!
    assert File.exist?(SimplesIdeias::I18n::JAVASCRIPT_DIR + "/i18n.js")
  end
  
  test "export messages.js" do
    SimplesIdeias::I18n.export!
    assert File.exist?(SimplesIdeias::I18n::JAVASCRIPT_DIR + "/messages.js")
  end
  
  test "rake should generate file" do
    `cd #{Rails.root} && rake i18n:generate`
    assert File.exist?(SimplesIdeias::I18n::JAVASCRIPT_DIR + "/messages.js")
  end
  
  test "rake should copy & generate files" do
    `cd #{Rails.root} && rake i18n:setup`
    assert File.exist?(SimplesIdeias::I18n::JAVASCRIPT_DIR + "/messages.js")
    assert File.exist?(SimplesIdeias::I18n::JAVASCRIPT_DIR + "/i18n.js")
  end
end
