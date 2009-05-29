require File.dirname(__FILE__) + "/test_helper"

module DeepTest
  unit_tests do
    test "a test that is put on can be taken off later" do
      blackboard = SimpleTestBlackboard.new
      test_case = TestFactory.passing_test
      blackboard.write_work test_case
      assert_equal test_case, blackboard.take_work
    end

    test "taking a test when all have been taken returns nil" do
      blackboard = SimpleTestBlackboard.new
      test_case = TestFactory.passing_test
      blackboard.write_work test_case
      blackboard.take_work
      assert_nil blackboard.take_work
    end

    test "a result that is put on can be taken off later" do
      blackboard = SimpleTestBlackboard.new
      result = TestFactory.passed_result
      blackboard.write_result result
      assert_equal result, blackboard.take_result
    end

    test "taking a result when all have been taken returns nil" do
      blackboard = SimpleTestBlackboard.new
      result = TestFactory.passed_result
      blackboard.write_result result
      blackboard.take_result
      assert_nil blackboard.take_result
    end
  end
end
