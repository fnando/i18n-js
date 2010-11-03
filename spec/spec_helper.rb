require "active_support/all"
require "active_support/version"
require "active_support/test_case"
require "ostruct"
require "pathname"
require "i18n"
require "json"
require "fakeweb"

FakeWeb.allow_net_connect = false

# Stub Rails.root, so we don"t need to load the whole Rails environment.
# Be careful! The specified folder will be removed!
Rails = OpenStruct.new({
  :root => Pathname.new(File.dirname(__FILE__) + "/tmp"),
  :version => "0"
})

require "i18n-js"
