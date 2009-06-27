require File.dirname(__FILE__) + '/../../lib/deep_test'

unless ARGV.length == 2
  puts "Usage: deep_test test_throughput <server uri> <test_count>"
  exit(1)
end

uri        = ARGV[0]
test_count = ARGV[1].to_i

options = DeepTest::Options.new(:distributed_server => uri,
                                :sync_options => {:source => ""})
server  = DeepTest::Distributed::TestServer.connect options
workers = DeepTest::Distributed::ThroughputWorkerClient.new(options, server)
runner  = DeepTest::Distributed::ThroughputRunner.new(options, test_count) do |result|
  $stdout.print "."
  $stdout.flush
end

start_time = Time.now
DeepTest::Main.new(options, workers, runner).run(false)
end_time = Time.now

puts
puts runner.statistics.summary

run_time = end_time.to_f - start_time.to_f
puts "Total Run Time: #{run_time} seconds"
puts "Run Time Not Spent On Tests: #{run_time - runner.statistics.timespan_in_seconds}"
