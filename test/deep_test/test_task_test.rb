require File.dirname(__FILE__) + '/../test_helper'

module DeepTest
  unit_tests do
    test "should support setting timeout_in_seconds" do
      t = TestTask.new :deep_test do |t|
        t.stubs(:desc)
        t.stubs(:task)
        t.timeout_in_seconds = 20
      end
      assert_equal 20, t.instance_variable_get(:@options).timeout_in_seconds
      assert_equal 20, t.timeout_in_seconds
    end

    test "should support listener" do
      t = TestTask.new :deep_test do |t|
        t.stubs(:desc)
        t.stubs(:task)
        t.listener = "A"
      end
      assert_equal "A", t.instance_variable_get(:@options).listener
      assert_equal "A", t.listener
    end
  end
end
