require "bundler"
Bundler::GemHelper.install_tasks

require "spec_js/rake_task"
SpecJs::RakeTask.new do |t|
  t.env_js = false
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:"spec:ruby")

desc "Run all specs"
task :spec => [:"spec:ruby", :"spec:js"]
