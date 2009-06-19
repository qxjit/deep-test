$LOAD_PATH << File.dirname(__FILE__) + "/../../vendor/gems/deep_test/lib"
gem 'rspec', '1.1.8'
require 'deep_test/rake_tasks'

DeepTest::TestTask.new(:deep_test) do |t|
  t.number_of_workers = 1
  t.pattern = "test/unit/**/*_test.rb"
  t.worker_listener = "ForeignHostWorkerSimulationListener,DeepTest::Database::MysqlSetupListener"
end
Rake::Task[:deep_test].enhance ["db:test:prepare"]

Spec::Rake::SpecTask.new(:deep_spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.deep_test :number_of_workers => 2
end
Rake::Task[:deep_spec].enhance ["db:test:prepare"]

DeepTest::TestTask.new(:distributed_test => %w[db:test:prepare]) do |t|
  t.number_of_workers = 1
  t.distributed_hosts = %w[localhost]
  t.requires = File.dirname(__FILE__) + "/../foreign_host_worker_simulation_listener"
  t.worker_listener = "ForeignHostWorkerSimulationListener,DeepTest::Database::MysqlSetupListener"
  t.sync_options = {:source => File.expand_path(File.dirname(__FILE__) + "/../.."), 
                    :rsync_options => "--exclude=.svn --copy-dirlinks"}
end
