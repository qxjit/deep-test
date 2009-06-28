require "socket"
require "base64"

require File.dirname(__FILE__) + "/options"
require File.dirname(__FILE__) + "/cpu_info"
require File.dirname(__FILE__) + "/test_task"
require File.dirname(__FILE__) + "/rspec_detector"

DeepTest::RSpecDetector.if_rspec_available do
  require 'spec/rake/spectask'
  require File.dirname(__FILE__) + "/spec/extensions/spec_task"
end

task :'deep_test:establish_beachhead' do
  require File.dirname(__FILE__) + "/../deep_test"
  options = DeepTest::Options.from_command_line(ENV['OPTIONS'])
  DeepTest.logger.debug { "mirror establish_beachhead for #{options.origin_hostname}" }

  STDIN.close

  beachhead = DeepTest::Distributed::Beachhead.new(
    options.mirror_path('/tmp'), options, DeepTest::Distributed::SshClientConnectionInfo.new
  ).daemonize(ENV['HOST']) do
    STDOUT.reopen("/tmp/deep_test_server.log", "a")
    STDERR.reopen(STDOUT)
  end

  puts "Beachhead url: #{beachhead.__drburi}"

  STDOUT.close
  STDERR.close
  exit!(0)
end
