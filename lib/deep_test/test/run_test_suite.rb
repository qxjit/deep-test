require File.dirname(__FILE__) + "/../../deep_test"
options = DeepTest::Options.from_command_line(ARGV[0])
main = DeepTest::Main.new options, options.new_deployment, DeepTest::Test::Runner.new(options) 
main.load_files Dir.glob(options.pattern)
main.run
