require 'rake'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require "deep_test"
require "deep_test/rake_tasks"

DeepTest::TestTask.new :deep_test_failing do |t|
  t.number_of_agents = 1
  t.pattern = "negative_acceptance_tests/failing.rb"
end

DeepTest::TestTask.new :deep_test_passing do |t|
  t.pattern = "negative_acceptance_tests/passing.rb"
end

DeepTest::TestTask.new :deep_test_failover_to_local do |t|
  t.number_of_agents = 1
  t.pattern = "negative_acceptance_tests/passing.rb"
  t.distributed_hosts = %w[foobar_host]
  t.sync_options = {:source => File.dirname(__FILE__), :rsync_options => "--exclude=.svn"}
end

DeepTest::TestTask.new :deep_test_just_one_with_host_down do |t|
  t.number_of_agents = 1
  t.pattern = "negative_acceptance_tests/passing.rb"
  t.distributed_hosts = %w[localhost foobar_host]
  t.sync_options = {:source => File.dirname(__FILE__), :rsync_options => "--exclude=.svn"}
end

DeepTest::TestTask.new :deep_test_with_agents_dying do |t|
  t.number_of_agents = 2
  t.pattern = "negative_acceptance_tests/dying.rb"
end
