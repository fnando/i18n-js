require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'ostruct'
require 'pathname'

# Stub Rails.root, so we don't need to load the whole Rails environment.
# Be careful! The specified folder will be removed!
Rails = OpenStruct.new(:root => Pathname.new(File.dirname(__FILE__) + "/tmp"))

require File.dirname(__FILE__) + '/../lib/i18n-js'
