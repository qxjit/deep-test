require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "retrying once" do
    object = Object.new
    object.expects(:call_it_twice).times(2).raises(RuntimeError).then.returns(:ok)
    result = nil
    capture_stdout do
      result = retrying do
        object.call_it_twice
      end
    end
    assert_equal :ok, result
  end
  
  test "retrying defaults to 5 times" do
    object = Object.new
    object.expects(:may_i_please_have_another).times(5).
      raises(RuntimeError).raises(RuntimeError).raises(RuntimeError).raises(RuntimeError).returns("ok")
    capture_stdout do
      retrying do
        object.may_i_please_have_another
      end
    end
  end
  
  test "retrying raises exception if still failing after number of attempts" do
    my_error = Class.new(StandardError)
    assert_raises(my_error) do
      capture_stdout do
        retrying "", 1 do
          raise my_error
        end
      end
    end
  end
end
