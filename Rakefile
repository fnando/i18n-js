require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.dirname(__FILE__) + '/lib/i18n-js/version'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the i18n-js plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the i18n-js plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'I18n for JavaScript'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'

  JEWEL = Jeweler::Tasks.new do |gem|
    gem.name = "i18n-js"
    gem.email = "fnando.vieira@gmail.com"
    gem.homepage = "http://github.com/fnando/i18n-js"
    gem.authors = ["Nando Vieira"]
    gem.version = SimplesIdeias::I18n::Version::STRING
    gem.summary = "It's a small library to provide the Rails I18n translations on the Javascript."
    gem.files =  FileList["README.rdoc", "init.rb", "install.rb", "{lib,test,source}/**/*", "Rakefile"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError => e
  puts "[JEWELER] You can't build a gem until you install jeweler with `gem install jeweler`"
end
