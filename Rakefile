# encoding: utf-8

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

# Import all rake files
for rakefile in Dir.glob('lib/tasks/*.rake')
  import(rakefile)
end
