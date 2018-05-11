# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*.rb', 'test/integration/*.rb']
end

desc "Run tests - note to pass opts use e.g. rake test TESTOPTS='-v'"
task default: :test
