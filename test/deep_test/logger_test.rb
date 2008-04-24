require File.dirname(__FILE__) + "/../test_helper"

unit_tests do
  test "info log level by default" do
    assert_equal Logger::INFO, DeepTest.logger.level
  end
  
  test "formatter uses msg only" do
    assert_equal "[DeepTest] my_msg\n", DeepTest.logger.formatter.call(nil, nil, nil, "my_msg")
  end
end
