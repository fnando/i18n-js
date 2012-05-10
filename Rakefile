require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:"spec:ruby")

desc "Run JavaScript specs"
task "spec:js" do
  system "jasmine-node", "spec/js"
end

desc "Run all specs"
task :spec => ["spec:ruby", "spec:js"]
