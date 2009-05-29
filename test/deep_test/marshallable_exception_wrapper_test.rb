require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "loading a marshallable exception evals the classname and returns an instance of the original exception" do
      original = RuntimeError.new "message"
      original.set_backtrace ['1', '2']

      marshalled = MarshallableExceptionWrapper.new(original)
      MarshallableExceptionWrapper.any_instance.expects(:eval).
        with("::RuntimeError").returns(RuntimeError)

      loaded = Marshal.load(Marshal.dump(marshalled)).resolve

      assert_equal original.class,     loaded.class
      assert_equal original.message,   loaded.message
      assert_equal original.backtrace, loaded.backtrace
    end

    test "loading a marshallable exception when class is not available returns an instance of unloadable exception" do
      original = RuntimeError.new "message"
      original.set_backtrace ['1', '2']

      marshalled = MarshallableExceptionWrapper.new(original)
      MarshallableExceptionWrapper.any_instance.expects(:eval).
        raises("Eval Error")

      loaded = Marshal.load(Marshal.dump(marshalled)).resolve

      assert_equal UnloadableException, loaded.class
      assert_equal "RuntimeError: " + original.message,   loaded.message
      assert_equal original.backtrace, loaded.backtrace
    end

    test "loading a marshallable exception when class init throws an error returns an unloadable exception" do
      original = RuntimeError.new "message"

      marshalled = MarshallableExceptionWrapper.new(original)
      RuntimeError.expects(:new).raises(StandardError.new)

      loaded = Marshal.load(Marshal.dump(marshalled)).resolve

      assert_equal UnloadableException, loaded.class
    end
  end
end
