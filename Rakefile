require 'rake'
require 'rake/testtask'
begin
  require 'rdoc/task'
rescue LoadError
  require 'rake/rdoctask'
end

desc 'Default: run unit tests.'
task :default => :test

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "mini-smtp-server"
    gemspec.summary = "A small and simple SMTP server"
    gemspec.description = "A small and simple SMTP server"
    gemspec.email = "aaron@aarongough.com"
    gemspec.homepage = "https://github.com/aarongough/mini-smtp-server"
    gemspec.authors = ["Aaron Gough"]
    gemspec.rdoc_options << '--line-numbers' << '--inline-source'
    gemspec.extra_rdoc_files = ['README.rdoc', 'MIT-LICENSE']
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end


desc 'Test mini-smtp-server.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib/*.rb'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end


desc 'Generate documentation for mini-smtp-server.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ruby-tmdb'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('app/**/*.rb')
end
