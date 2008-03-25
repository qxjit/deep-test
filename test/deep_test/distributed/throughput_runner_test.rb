require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "runner adds specified number of work units to blackboard" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    runner = DeepTest::Distributed::ThroughputRunner.new(
      DeepTest::Options.new({}),
      5,
      blackboard
    )

    worker = ThreadWorker.new(blackboard, 5)
    Timeout.timeout(5) do
      runner.process_work_units
    end
    worker.wait_until_done
  end

  test "runner yields all results from blackboard" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    count = 0
    runner = DeepTest::Distributed::ThroughputRunner.new(
      DeepTest::Options.new({}),
      2,
      blackboard
    ) do |result|
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
    blackboard = DeepTest::SimpleTestBlackboard.new
    runner = DeepTest::Distributed::ThroughputRunner.new(
      DeepTest::Options.new({}),
      2,
      blackboard
    )

    worker = ThreadWorker.new(blackboard, 2)
    count = 0
    Timeout.timeout(5) do
      runner.process_work_units
    end
    worker.wait_until_done

    assert_kind_of DeepTest::Distributed::ThroughputStatistics,
                   runner.statistics
  end

  test "runner returns true" do
    runner = DeepTest::Distributed::ThroughputRunner.new(
      DeepTest::Options.new({}),
      0,
      DeepTest::SimpleTestBlackboard.new 
    )

    assert_equal true, runner.process_work_units
  end
end
