require File.dirname(__FILE__) + "/../lib/deep_test"
require 'drb/drb'
require 'optparse'

config = DeepTest::Distributed::MirrorServer.parse_args(ARGV)

#
# Clear args so they won't be processed in any forked processes.
#    - When specs are loaded by the RemoteWorkerServer, RSpec
#      attempts to parse ARGV
#
ARGV.clear

begin
  DeepTest::Distributed::MirrorServer.start(config)
rescue Interrupt
  DeepTest.logger.info "Exiting due to Interrupt"
end
