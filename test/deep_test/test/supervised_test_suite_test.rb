require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Test
    unit_tests do
      test "run yields name for start and finished of underlying suite" do
        options = Options.new({})
        suite = ::Test::Unit::TestSuite.new("name")
        supervised_suite = SupervisedTestSuite.new(suite, TestCentralCommand.start(options))

        yielded = []
        supervised_suite.run(stub_everything) do |channel,name|
          yielded << [channel,name]
        end

        assert_equal [[::Test::Unit::TestSuite::STARTED, "name"],
                      [::Test::Unit::TestSuite::FINISHED, "name"]], yielded
      end

      test "run adds tests to central_command and reads results" do
        options = Options.new({})
        class AddTestsTestCase < ::Test::Unit::TestCase
          test("1") {}
          test("2") {assert_equal true, false}
        end
        central_command = TestCentralCommand.start options
        supervised_suite = SupervisedTestSuite.new(AddTestsTestCase.suite, central_command)
        result = ::Test::Unit::TestResult.new

        agent = ThreadAgent.new options
        Timeout.timeout(5) do
          supervised_suite.run(result) {}
        end
        central_command.done_with_work
        agent.wait_until_done

        assert_equal 2, result.run_count
        assert_equal 1, result.failure_count
      end

      test "agent errors are counted as errors" do
        options = Options.new({})
        class AgentErrorTestCase < ::Test::Unit::TestCase
          test("1") {}
        end

        central_command = TestCentralCommand.start options
        supervised_suite = SupervisedTestSuite.new(AgentErrorTestCase.suite, central_command)
        result = ::Test::Unit::TestResult.new

        central_command.write_result Agent::Error.new(AgentErrorTestCase.new("test_1"), RuntimeError.new)
        capture_stdout {supervised_suite.run(result) {}}

        assert_equal 1, result.error_count
      end

      test "multiple agent errors are consolidated to be one error" do
        options = Options.new({})
        class MultipleAgentErrorTestCase < ::Test::Unit::TestCase
          test("1") {}; test("2") {}
        end
        central_command = TestCentralCommand.start options
        supervised_suite = SupervisedTestSuite.new(MultipleAgentErrorTestCase.suite, central_command)
        result = ::Test::Unit::TestResult.new

        central_command.write_result Agent::Error.new(MultipleAgentErrorTestCase.new("test_1"), RuntimeError.new)
        central_command.write_result Agent::Error.new(MultipleAgentErrorTestCase.new("test_2"), RuntimeError.new)
        capture_stdout {supervised_suite.run(result) {}}

        assert_equal 1, result.error_count
      end

      test "run yields test case finished events" do
        options = Options.new({})
        class RunYieldsTestCase < ::Test::Unit::TestCase
          test("1") {}
        end
        test_case = RunYieldsTestCase.new("test_1")

        central_command = TestCentralCommand.start options
        supervised_suite = SupervisedTestSuite.new(test_case, central_command)

        yielded = []

        agent = ThreadAgent.new options
        Timeout.timeout(5) do
          supervised_suite.run(stub_everything) do |channel,name|
            yielded << [channel, name]
          end
        end
        central_command.done_with_work
        agent.wait_until_done

        assert_equal true, yielded.include?([::Test::Unit::TestCase::FINISHED, test_case.name])
      end

      test "has same size as underlying suite" do
        options = Options.new({})
        suite = ::Test::Unit::TestSuite.new("name")
        suite << "test"
        supervised_suite = SupervisedTestSuite.new(suite, TestCentralCommand.start(options))
        
        assert_equal suite.size, supervised_suite.size
      end
    end
  end
end
