require File.dirname(__FILE__) + '/../test_helper'

unit_tests do
  test "take result waits 30 seconds before timing out" do
    blackboard = DeepTest::RindaBlackboard.new(DeepTest::Options.new({}), tuple_space = stub)
    tuple_space.expects(:take).with(["test_result", nil], 30).returns([])
    blackboard.take_result
  end

  test "take test waits 30 seconds before timing out" do
    blackboard = DeepTest::RindaBlackboard.new(DeepTest::Options.new({}), tuple_space = stub)
    tuple_space.expects(:take).with(["deep_work", nil], 30).returns([nil, "String"])
    blackboard.take_work
  end
end
