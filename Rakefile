require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "test/*.rb"
end

desc "Run tests - note to pass opts use e.g. rake test TESTOPTS='-v'"
task :default => :test
