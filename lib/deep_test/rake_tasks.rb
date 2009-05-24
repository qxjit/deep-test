require "socket"
require "base64"

require File.dirname(__FILE__) + "/options"
require File.dirname(__FILE__) + "/test_task"
require File.dirname(__FILE__) + "/rspec_detector"

DeepTest::RSpecDetector.if_rspec_available do
  require 'spec/rake/spectask'
  require File.dirname(__FILE__) + "/spec/extensions/spec_task"
end

task :start_ad_hoc_deep_test_server do
require File.dirname(__FILE__) + "/../deep_test"
  options = DeepTest::Options.from_command_line(ENV['OPTIONS'])
  DeepTest.logger.debug("mirror spawn_worker_server for #{options.origin_hostname}")

  STDIN.close

  server = DeepTest::Distributed::RemoteWorkerServer.start(
    'localhost',
    options.mirror_path('/tmp'),
    DeepTest::Distributed::TestServerWorkers.new(
      options, 
      {:number_of_workers => 2}, 
      DeepTest::Distributed::SshClientConnectionInfo.new
    )
  ) do
    STDOUT.reopen("/tmp/ad_hoc_deep_test_server.log", "a")
    STDERR.reopen(STDOUT)
  end

  puts "RemoteWorkerServer url: #{server.__drburi}"

  STDOUT.close
  STDERR.close
  exit!(0)
end
