require File.dirname(__FILE__) + "/../../lib/deep_test"
options = DeepTest::Options.from_command_line(ARGV[0])
DeepTest.init(options)
runner = DeepTest::Test::Runner.new(options)
deployment = options.new_deployment
deployment.load_files Dir.glob(options.pattern)
DeepTest::Main.run(options, deployment, runner)
