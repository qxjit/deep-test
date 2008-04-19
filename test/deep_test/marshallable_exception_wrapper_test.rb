require File.dirname(__FILE__) + "/../test_helper"

unit_tests do
  test "loading a marshallable exception evals the classname and returns an instance of the original exception" do
    original = RuntimeError.new "message"
    original.set_backtrace ['1', '2']

    marshalled = DeepTest::MarshallableExceptionWrapper.new(original)
    DeepTest::MarshallableExceptionWrapper.any_instance.expects(:eval).
      with("::RuntimeError").returns(RuntimeError)

    loaded = Marshal.load(Marshal.dump(marshalled)).resolve

    assert_equal original.class,     loaded.class
    assert_equal original.message,   loaded.message
    assert_equal original.backtrace, loaded.backtrace
  end

  test "loading a marshallable exception when class is not available returns an instance of unloadable exception" do
    original = RuntimeError.new "message"
    original.set_backtrace ['1', '2']

    marshalled = DeepTest::MarshallableExceptionWrapper.new(original)
    DeepTest::MarshallableExceptionWrapper.any_instance.expects(:eval).
      raises("Eval Error")

    loaded = Marshal.load(Marshal.dump(marshalled)).resolve

    assert_equal DeepTest::UnloadableException, loaded.class
    assert_equal "RuntimeError: " + original.message,   loaded.message
    assert_equal original.backtrace, loaded.backtrace
  end
end
