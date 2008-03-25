require File.dirname(__FILE__) + "/../lib/deep_test"
require 'drb/drb'
require 'optparse'

uri = "druby://#{Socket.gethostname}:8000"
slave_uris = OptionParser.new do |opts|
  opts.banner = "Usage: master_mirror_server.rb [options] <mirror_server_uris>"

  opts.on("--uri URI", "DRb URI to bind server to") do |v|
    uri = v
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse(ARGV)

begin
  DeepTest::Distributed::MasterMirrorServer.start(uri, slave_uris)
rescue Interrupt
  DeepTest.logger.info "Exiting due to Interrupt"
end

