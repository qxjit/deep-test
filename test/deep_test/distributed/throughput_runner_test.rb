require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "runner adds specified number of work units to central_command" do
        central_command = SimpleTestCentralCommand.new
        runner = ThroughputRunner.new(Options.new({}), 5, central_command)

        agent = ThreadAgent.new(central_command, 5)
        Timeout.timeout(5) do
          runner.process_work_units
        end
        agent.wait_until_done
      end

      test "runner yields all results from central_command" do
        central_command = SimpleTestCentralCommand.new
        count = 0
        runner = ThroughputRunner.new(Options.new({}), 2, central_command) do |result|
          assert_equal :null_work_unit_result, result
          count += 1
        end

        agent = ThreadAgent.new(central_command, 2)
        Timeout.timeout(5) do
          runner.process_work_units
        end
        agent.wait_until_done

        assert_equal 2, count
      end

      test "statistics are available after run" do
        central_command = SimpleTestCentralCommand.new
        runner = ThroughputRunner.new(Options.new({}), 2, central_command)

        agent = ThreadAgent.new(central_command, 2)
        count = 0
        Timeout.timeout(5) do
          runner.process_work_units
        end
        agent.wait_until_done

        assert_kind_of ThroughputStatistics, runner.statistics
      end

      test "runner returns true" do
        runner = ThroughputRunner.new(
          Options.new({}), 0, SimpleTestCentralCommand.new 
        )

        assert_equal true, runner.process_work_units
      end
    end
  end
end
