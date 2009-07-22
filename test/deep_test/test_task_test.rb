require File.dirname(__FILE__) + '/../test_helper'

module DeepTest
  unit_tests do
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
