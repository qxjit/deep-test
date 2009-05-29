require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "runner adds specified number of work units to blackboard" do
        blackboard = SimpleTestBlackboard.new
        runner = ThroughputRunner.new(Options.new({}), 5, blackboard)

        worker = ThreadWorker.new(blackboard, 5)
        Timeout.timeout(5) do
          runner.process_work_units
        end
        worker.wait_until_done
      end

      test "runner yields all results from blackboard" do
        blackboard = SimpleTestBlackboard.new
        count = 0
        runner = ThroughputRunner.new(Options.new({}), 2, blackboard) do |result|
          assert_equal :null_work_unit_result, result
          count += 1
        end

        worker = ThreadWorker.new(blackboard, 2)
        Timeout.timeout(5) do
          runner.process_work_units
        end
        worker.wait_until_done

        assert_equal 2, count
      end

      test "statistics are available after run" do
        blackboard = SimpleTestBlackboard.new
        runner = ThroughputRunner.new(Options.new({}), 2, blackboard)

        worker = ThreadWorker.new(blackboard, 2)
        count = 0
        Timeout.timeout(5) do
          runner.process_work_units
        end
        worker.wait_until_done

        assert_kind_of ThroughputStatistics, runner.statistics
      end

      test "runner returns true" do
        runner = ThroughputRunner.new(
          Options.new({}), 0, SimpleTestBlackboard.new 
        )

        assert_equal true, runner.process_work_units
      end
    end
  end
end
