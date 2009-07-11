require 'rake'
require 'rake/testtask'

task :default => %w[
  test 
]

task :pc => :default

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
  t.libs += ['test', 'lib']
end

