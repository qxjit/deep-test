require File.dirname(__FILE__) + '/../test_helper'

unit_tests do
  test "take result waits 30 seconds before timing out" do
    blackboard = DeepTest::RindaBlackboard.new(tuple_space = stub)
    tuple_space.expects(:take).with(["test_result", nil], 30).returns([])
    blackboard.take_result
  end

  test "take test waits 30 seconds before timing out" do
    blackboard = DeepTest::RindaBlackboard.new(tuple_space = stub)
    tuple_space.expects(:take).with(["run_test", nil, nil], 30).returns([nil, "String", "foo"])
    blackboard.take_test
  end
end