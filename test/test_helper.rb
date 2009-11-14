require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'

# Stub RAILS_ROOT to get proper files writing location in every environments
# Keep really careful with this files path as this folder is going to be removed !!!
RAILS_ROOT = File.dirname(__FILE__) + "/tmp"

require File.dirname(__FILE__) + '/../lib/i18n-js'