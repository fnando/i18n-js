require 'test_helper'

class I18nJSTest < ActiveSupport::TestCase
  setup do
    # Remove temporary directory if already present
    FileUtils.rm_r(RAILS_ROOT) if File.exist?(RAILS_ROOT)

    # Create temporary directory to test the files generation
    FileUtils.mkdir_p([RAILS_ROOT+"/config", RAILS_ROOT+"/public/javascripts/", RAILS_ROOT+"/public/javascripts/folder"])

    # Overwrite defaut locales path to use fixtures
    I18n.load_path = [File.dirname(__FILE__)+"/fixtures/locales.yml"]
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
    SimplesIdeias::I18n.export!(load_test_config!)
    assert File.exist?(RAILS_ROOT+'/public/javascripts/messages.js')
    assert File.exist?(RAILS_ROOT+'/public/javascripts/basic_scope.js')
    assert File.exist?(RAILS_ROOT+'/public/javascripts/simple_scope.js')
    assert File.exist?(RAILS_ROOT+'/public/javascripts/completion_scope.js')
    assert File.exist?(RAILS_ROOT+'/public/javascripts/deep_completion_scope.js')
    assert File.exist?(RAILS_ROOT+'/public/javascripts/multi_completion.js')
    assert File.exist?(RAILS_ROOT+'/public/javascripts/folder/multi_scopes.js')
  end

  %w( messages.js basic_scope.js simple_scope.js completion_scope.js deep_completion_scope.js multi_completion.js folder/multi_scopes.js ).each do |file|
    test "export! : file validity : #{file}" do
      SimplesIdeias::I18n.export!(load_test_config!)
      # Base test on file size as key order varies
      assert_equal File.size(File.dirname(__FILE__)+"/fixtures/expected_results/#{file}"), File.size(RAILS_ROOT+"/public/javascripts/#{file}")
    end
  end

  test "setup! : copy conf file" do
    SimplesIdeias::I18n.setup!
    assert File.exist?(::SimplesIdeias::I18n::CONFIG_FILE)
  end

  test "setup! : raise error if no i18n_dir in conf" do
    FileUtils.copy(File.dirname(__FILE__)+'/fixtures/i18n-js-invalid-i18n_dir.yml', RAILS_ROOT+"/config/i18n-js.yml")
    puts ::SimplesIdeias::I18n::INVALID_I18N_DIR
    assert_raise RuntimeError do
      SimplesIdeias::I18n.setup!
    end
  end

  test "setup! : copy i18n.js" do
    SimplesIdeias::I18n.setup!
    assert File.exist?(RAILS_ROOT+'/public/javascripts/i18n.js')
  end

  test "setup! : copy i18n.js to custom dir" do
    FileUtils.copy(File.dirname(__FILE__)+'/fixtures/i18n-js-custom-i18n_dir.yml', RAILS_ROOT+"/config/i18n-js.yml")
    SimplesIdeias::I18n.setup!
    assert File.exist?(RAILS_ROOT+'/public/javascripts/folder/i18n.js')
  end

  test "setup! : generate messages files" do
    SimplesIdeias::I18n.setup!
    assert File.exist?(RAILS_ROOT+'/public/javascripts/messages.js')
  end

  private

    def load_test_config!
      YAML.load(File.open(File.dirname(__FILE__) + '/fixtures/i18n-js.yml'))
    end
end
