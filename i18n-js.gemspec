# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "i18n/js/version"

Gem::Specification.new do |s|
  s.name        = "i18n-js"
  s.version     = I18n::JS::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/i18n-js"
  s.summary     = "It's a small library to provide the Rails I18n translations on the Javascript."
  s.description = s.summary

  s.files         = Dir["{lib,vendor,config}/**/*"] + ["README.rdoc", "Rakefile"]
  s.test_files    = Dir["spec/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency "i18n", "~> 0.6"
  s.add_development_dependency "appraisal", "~> 1.0"
  s.add_development_dependency "activesupport", ">= 3"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry-meta"
end
