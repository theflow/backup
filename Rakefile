require 'rake'
require 'rake/testtask'

task :default => [:test]

desc 'Run tests'
Rake::TestTask.new(:test) do |t|
  t.libs << "tests"
  t.pattern = 'tests/*_test.rb'
  t.verbose = true
end
