require File.dirname(__FILE__) + "/test_helper"

unit_tests do
  test "puts result on blackboard" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    blackboard.write_test TestFactory.passing_test

    DeepTest::Worker.new(blackboard).run

    assert_kind_of Test::Unit::TestResult, blackboard.take_result
  end

  test "puts passing and failing tests on blackboard for each test" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    blackboard.write_test TestFactory.passing_test
    blackboard.write_test TestFactory.failing_test

    DeepTest::Worker.new(blackboard).run

    result_1 = blackboard.take_result
    result_2 = blackboard.take_result

    assert_equal true, (result_1.passed? || result_2.passed?)
    assert_equal false, (result_1.passed? && result_2.passed?)
  end
  
  test "capturing stdout" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    blackboard.write_test TestFactory.passing_test_with_stdout
    DeepTest::Worker.new(blackboard).run
    result = blackboard.take_result
    assert_equal "message printed to stdout", result.output
  end
end
