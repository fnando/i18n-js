require "i18n"
require "json"

require "active_support/all"
require "i18n/js"

module Helpers
  # Set the configuration as the current one
  def set_config(path)
    config_file_path = File.dirname(__FILE__) + "/fixtures/#{path}"
    I18n::JS.stub(:config? => true, :config_file_path => config_file_path)
  end

  # Shortcut to I18n::JS.translations
  def translations
    I18n::JS.translations
  end

  def file_should_exist(name)
    file_path = File.join(temp_path, name)
    File.should be_file(file_path)
  end

  def temp_path(file_name = "")
    File.expand_path("../../tmp/i18n-js/#{file_name}", __FILE__)
  end


  def self.included(base)
    base.let(:backend_class_with_fallbacks) do
      klass = Class.new(I18n::Backend::Simple)
      klass.send(:include, I18n::Backend::Fallbacks)
      klass
    end
  end
end

RSpec.configure do |config|
  config.before do
    I18n.load_path = [File.dirname(__FILE__) + "/fixtures/locales.yml"]
    FileUtils.rm_rf(temp_path)
  end

  config.after do
    FileUtils.rm_rf(temp_path)
  end

  config.include Helpers

  # Remove deprecation warnings
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

