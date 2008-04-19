require File.dirname(__FILE__) + "/../../../test_helper"

unit_tests do
  test "make_exception_marshallable wraps exception in a mashallable exception" do
    error = Test::Unit::Error.new "test_name", Exception.new("message")
    error.make_exception_marshallable

    assert_kind_of DeepTest::MarshallableExceptionWrapper, error.exception
  end

  test "calling make_exception_marshallable twice only wraps exception once" do
    error = Test::Unit::Error.new "test_name", Exception.new("message")
    error.make_exception_marshallable
    error.make_exception_marshallable

    assert_kind_of DeepTest::MarshallableExceptionWrapper, error.exception
  end

  test "error is accessible as normal when it has not been made marshallable" do
    error = Test::Unit::Error.new "test_name", e = Exception.new("message")
    assert_equal e, error.exception
  end

  test "resolve_marshallable_exception restores the original exception" do
    error = Test::Unit::Error.new "test_name", Exception.new("message")
    error.make_exception_marshallable
    error.resolve_marshallable_exception

    assert_kind_of Exception, error.exception
    assert_equal   'message', error.exception.message
  end

  test "resolve_marshallable_exception does not fail when exception has not been made marshallable" do
    error = Test::Unit::Error.new "test_name", Exception.new("message")
    error.resolve_marshallable_exception

    assert_kind_of Exception, error.exception
    assert_equal   'message', error.exception.message
  end
end
