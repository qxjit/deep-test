require File.dirname(__FILE__) + "/test_helper"

unit_tests do
  test "add_to adds correct run_count" do
    result_1 = Test::Unit::TestResult.new
    result_1.add_run
    result_1.add_run

    result_2 = Test::Unit::TestResult.new
    result_1.add_to result_2

    assert_equal 2, result_2.run_count
  end

  test "add_to adds correct assertion_count" do
    result_1 = Test::Unit::TestResult.new
    result_1.add_assertion
    result_1.add_assertion

    result_2 = Test::Unit::TestResult.new
    result_1.add_to result_2

    assert_equal 2, result_2.assertion_count
  end

  test "add_to adds correct errors" do
    result_1 = Test::Unit::TestResult.new
    result_1.add_error(:error)

    result_2 = Test::Unit::TestResult.new
    result_1.add_to result_2

    assert_equal [:error], result_2.instance_variable_get(:@errors)
  end


  test "add_to adds correct failures" do
    result_1 = Test::Unit::TestResult.new
    result_1.add_failure(:failure)

    result_2 = Test::Unit::TestResult.new
    result_1.add_to result_2

    assert_equal [:failure], result_2.instance_variable_get(:@failures)
  end
  
  test "wraps exceptions" do
    result = Test::Unit::TestResult.new
    begin
      raise SomeCustomException.new("the exception message")
    rescue => ex
      result.add_error Test::Unit::Error.new("test_wraps_exceptions", ex)
    end
    error = result.instance_variable_get("@errors").last
    # TODO: add this assertion
    # assert_equal "SomeCustomException: the exception message", error.message
    assert_equal "SomeCustomException: the exception message", error.exception.message
    assert_equal Exception, error.exception.class
    assert_equal ex.backtrace, error.exception.backtrace
  end
end
