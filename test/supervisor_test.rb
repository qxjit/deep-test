require File.dirname(__FILE__) + "/test_helper"

unit_tests do
  test "add_tests adds single test to blackboard" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    supervisor = DeepTest::Supervisor.new(blackboard)
    test_case = TestFactory.passing_test
    supervisor.add_tests test_case
    assert_equal test_case, blackboard.take_test
  end

  test "add_tests adds entire suite to blackboard" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    supervisor = DeepTest::Supervisor.new(blackboard)
    test_suite = TestFactory.suite
    test_suite << (test_case_1 = TestFactory.passing_test)
    test_suite << (test_case_2 = TestFactory.passing_test)

    supervisor.add_tests test_suite

    actual_tests = [blackboard.take_test, blackboard.take_test]

    assert_equal true, actual_tests.member?(test_case_1), 
                       "First test case is not on blackboard"

    assert_equal true, actual_tests.member?(test_case_2),
                       "Second test case is not on blackboard"
  end

  test "read_results adds blackboard result to local result" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    supervisor = DeepTest::Supervisor.new(blackboard)

    supervisor.add_tests TestFactory.passing_test

    blackboard_result = Test::Unit::TestResult.new
    blackboard_result.add_run

    blackboard.write_result blackboard_result

    local_result = Test::Unit::TestResult.new
    supervisor.read_results local_result

    assert_equal 1, local_result.run_count
  end

  test "read_results yields TestCase::Finished event when reading a result" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    supervisor = DeepTest::Supervisor.new(blackboard)

   supervisor.add_tests TestFactory.passing_test

    blackboard.write_result Test::Unit::TestResult.new
    yielded = nil

    supervisor.read_results Test::Unit::TestResult.new do |channel,name|
      yielded = [channel,name]
    end

    assert_equal [Test::Unit::TestCase::FINISHED, nil], yielded
  end
  
  test "read_results prints output if any" do
     blackboard = DeepTest::SimpleTestBlackboard.new
     supervisor = DeepTest::Supervisor.new(blackboard)
     supervisor.add_tests stub
     result = Test::Unit::TestResult.new
     result.output = "output"
     blackboard.write_result result
     supervisor.expects(:print).with("output")
     supervisor.read_results Test::Unit::TestResult.new do |channel,name|
     end
  end
end
