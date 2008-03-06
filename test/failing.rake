require 'rake'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require "deep_test"
require "deep_test/rake_tasks"

task :default => %w[deep_test_failing]

DeepTest::TestTask.new :deep_test_failing do |t|
  t.number_of_workers = 1
  t.pattern = "test/failing.rb"
end
