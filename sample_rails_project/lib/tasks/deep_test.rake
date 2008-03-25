$LOAD_PATH << File.dirname(__FILE__) + "/../../../lib"
require 'deep_test/rake_tasks'

DeepTest::TestTask.new(:deep_test) do |t|
  t.number_of_workers = 1
  t.pattern = "test/unit/**/*_test.rb"
  t.worker_listener = "ForeignHostWorkerSimulationListener,DeepTest::Database::MysqlSetupListener"
end
Rake::Task[:deep_test].enhance ["db:test:prepare"]
