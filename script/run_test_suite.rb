require File.dirname(__FILE__) + "/../lib/deep_test"
options = DeepTest::Options.from_command_line(ARGV[0])
runner = DeepTest::Test::Runner.new(options)
runner.load_files
DeepTest::ProcessOrchestrator.run(options, runner)
