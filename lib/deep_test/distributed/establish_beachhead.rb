require File.dirname(__FILE__) + "/../../deep_test"
options = DeepTest::Options.from_command_line(ENV['OPTIONS'])
options.ssh_client_connection_info = DeepTest::Distributed::SshClientConnectionInfo.new
DeepTest.logger.debug { "mirror establish_beachhead for #{options.origin_hostname}" }

STDIN.close

beachhead_port = DeepTest::Distributed::Beachhead.new(
  File.join(options.mirror_path, File.basename(options.sync_options[:source])), 
  options
).daemonize

puts "Beachhead port: #{beachhead_port}"
$stdout.flush

exit!(0)

