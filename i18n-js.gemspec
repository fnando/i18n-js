# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "i18n-js/version"

Gem::Specification.new do |s|
  s.name        = "i18n-js"
  s.version     = SimplesIdeias::I18n::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/i18n-js"
  s.summary     = "It's a small library to provide the Rails I18n translations on the Javascript."
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "i18n"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "activesupport", ">= 3.0.0"
  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "spec-js", "~> 0.1.0.beta.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
end
