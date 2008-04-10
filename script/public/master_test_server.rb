require File.dirname(__FILE__) + "/../../lib/deep_test"
require 'drb/drb'
require 'optparse'

uri = "druby://:4021"
slave_uris = OptionParser.new do |opts|
  opts.banner = "Usage: deep_test master_test_server [options] <test_server_uris>"

  opts.on("--uri URI", "DRb URI to bind server to") do |v|
    uri = v
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse(ARGV)

begin
  DeepTest::Distributed::MasterTestServer.start(uri, slave_uris)
rescue Interrupt
  DeepTest.logger.info "Exiting due to Interrupt"
end

