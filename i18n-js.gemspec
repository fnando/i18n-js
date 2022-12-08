# frozen_string_literal: true

require_relative "./lib/i18n-js/version"

Gem::Specification.new do |spec|
  spec.name    = "i18n-js"
  spec.version = I18nJS::VERSION
  spec.authors = ["Nando Vieira"]
  spec.email   = ["me@fnando.com"]

  spec.summary     = "Export i18n translations and use them on JavaScript."
  spec.description = spec.summary
  spec.license     = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")
  spec.metadata = {"rubygems_mfa_required" => "true"}

  github_url = "https://github.com/fnando/i18n-js"
  github_tree_url = "#{github_url}/tree/v#{spec.version}"

  spec.homepage = github_url
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{github_url}/issues"
  spec.metadata["source_code_uri"] = github_tree_url
  spec.metadata["changelog_uri"] = "#{github_tree_url}/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "#{github_tree_url}/README.md"
  spec.metadata["license_uri"] = "#{github_tree_url}/LICENSE.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`
      .split("\x0")
      .reject {|f| f.match(%r{^(test|spec|features|images)/}) }
  end

  spec.files << "lib/i18n-js/lint.js"

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "glob", ">= 0.4.0"
  spec.add_dependency "i18n"

  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-utils"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "pry-meta"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-fnando"
  spec.add_development_dependency "simplecov"
end
