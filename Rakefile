require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:"spec:ruby")

desc "Run all specs"
task :spec => [:"spec:ruby"]

task :default => :spec
