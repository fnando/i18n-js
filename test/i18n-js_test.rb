require 'test_helper'

class I18nJSTest < ActiveSupport::TestCase
  setup do
    # Remove temporary directory if already present
    FileUtils.rm_r(RAILS_ROOT) if File.exist?(RAILS_ROOT)

    # Create temporary directory to test the files generation
    FileUtils.mkdir_p([RAILS_ROOT+"/config", RAILS_ROOT+"/public/javascripts/"])

    # Load test config file
    @config = YAML.load(File.open(File.dirname(__FILE__) + '/fixtures/i18n-js.yml'))
  end
  
  teardown do
    # Remove temporary directory
    FileUtils.rm_r(RAILS_ROOT)
  end

  test "export! : copy config if not found" do
    assert !File.exist?(::SimplesIdeias::I18n::CONFIG_FILE)
    SimplesIdeias::I18n.export!
    assert File.exist?(::SimplesIdeias::I18n::CONFIG_FILE)
  end

  test "export! : export messages files" do
    # FIXME: Stub I18n to depend on fixtures/locales.yml
    SimplesIdeias::I18n.export!(@config)
  end
  
  # FIXME: Add rest of the tests
end
