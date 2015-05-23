require 'rake/testtask'
require 'rubygems/package_task'
require 'bundler'

task :default => :test

Rake::TestTask.new do |test|
  test.pattern = 'tests/*.rb'
  test.verbose = true
end

Bundler::GemHelper.install_tasks

