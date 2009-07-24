require 'rake'
require 'rubygems'
gem 'rspec', '1.1.12'
require 'spec/rake/spectask'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require "deep_test"
require "deep_test/rake_tasks"

DeepTest::TestTask.new :deep_test_failing do |t|
  t.number_of_agents = 1
  t.pattern = "negative_acceptance_tests/failing_test.rb"
end

DeepTest::TestTask.new :deep_test_passing do |t|
  t.pattern = "negative_acceptance_tests/passing_test.rb"
end

DeepTest::TestTask.new :deep_test_failover_to_local do |t|
  t.number_of_agents = 1
  t.pattern = "negative_acceptance_tests/passing_test.rb"
  t.distributed_hosts = %w[host.foobar]
  t.sync_options = {:source => File.dirname(__FILE__), :rsync_options => "--exclude=.svn"}
end

DeepTest::TestTask.new :deep_test_just_one_with_host_down do |t|
  t.number_of_agents = 1
  t.pattern = "negative_acceptance_tests/passing_test.rb"
  t.distributed_hosts = %w[localhost host.foobar]
  t.sync_options = {:source => File.dirname(__FILE__), :rsync_options => "--exclude=.svn"}
end

DeepTest::TestTask.new :deep_test_with_agents_dying do |t|
  t.number_of_agents = 1
  t.pattern = "negative_acceptance_tests/dying_test.rb"
end

DeepTest::TestTask.new :deep_test_with_work_taken_and_not_done do |t|
  t.number_of_agents = 2
  t.listener = "KillAgentOneOnStartWork"
  t.requires = 'negative_acceptance_tests/kill_agent_one_on_start_work.rb'
  t.pattern = "negative_acceptance_tests/passing_test.rb"
end

Spec::Rake::SpecTask.new :deep_spec_failing do |t|
  t.deep_test :number_of_agents => 1
  t.spec_files = FileList["negative_acceptance_tests/failing_spec.rb"]
end

Spec::Rake::SpecTask.new :deep_spec_passing do |t|
  t.deep_test :number_of_agents => 1
  t.spec_files = FileList["negative_acceptance_tests/passing_spec.rb"]
end

Spec::Rake::SpecTask.new :deep_spec_failover_to_local do |t|
  t.deep_test :number_of_agents => 1,
              :distributed_hosts => %w[host.foobar],
              :sync_options => {:source => File.dirname(__FILE__), :rsync_options => "--exclude=.svn"}
  t.spec_files = FileList["negative_acceptance_tests/passing_spec.rb"]
end

Spec::Rake::SpecTask.new :deep_spec_just_one_with_host_down do |t|
  t.deep_test :number_of_agents => 1,
              :distributed_hosts => %w[localhost host.foobar],
              :sync_options => {:source => File.dirname(__FILE__), :rsync_options => "--exclude=.svn"}
  t.spec_files = FileList["negative_acceptance_tests/passing_spec.rb"]
end

Spec::Rake::SpecTask.new :deep_spec_with_agents_dying do |t|
  t.deep_test :number_of_agents => 2
  t.spec_files = FileList["negative_acceptance_tests/dying_spec.rb"]
end

Spec::Rake::SpecTask.new :deep_spec_with_work_taken_and_not_done do |t|
  t.spec_files = FileList['negative_acceptance_tests/kill_agent_one_on_start_work.rb',
                          "negative_acceptance_tests/passing_test.rb"]
  t.deep_test :number_of_agents => 2, :listener => "KillAgentOneOnStartWork"
end
