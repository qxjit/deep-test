require File.dirname(__FILE__) + "/../../deep_test"
options = DeepTest::Options.from_command_line(ENV['OPTIONS'])
DeepTest.logger.debug { "mirror establish_beachhead for #{options.origin_hostname}" }

STDIN.close

beachhead_port = DeepTest::Distributed::Beachhead.new(
  File.join(options.mirror_path('/tmp'), File.basename(options.sync_options[:source])), 
  options
).daemonize

puts "Beachhead port: #{beachhead_port}"
$stdout.flush

exit!(0)

