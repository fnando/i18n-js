# frozen_string_literal: true

ENV["TZ"] = "Etc/UTC"

require "simplecov"
SimpleCov.start do
  add_filter(/test/)
end

require "bundler/setup"
require "i18n-js"
require "i18n-js/cli"

require "minitest/utils"
require "minitest/autorun"

Dir["./test/support/**/*.rb"].each do |file|
  require file
end
