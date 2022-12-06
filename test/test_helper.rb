# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter(/test/)
end

require "bundler/setup"
require "i18n-js"
require "i18n-js/cli"

require "minitest/utils"
require "minitest/autorun"

Dir["./test/support/**/*.rb"].sort.each do |file|
  require file
end
