require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "dispatch_finished doesn't fail if spinner is nil" do
    assert_nothing_raised do
      DeepTest::UI::Console.new(:options).dispatch_finished(:method_name)
    end
  end
end
