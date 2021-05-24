# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "bundler/setup"
require "i18n-js"

require "minitest/utils"
require "minitest/autorun"

Dir["./test/support/**/*.rb"].sort.each do |file|
  require file
end
