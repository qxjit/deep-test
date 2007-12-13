require File.dirname(__FILE__) + '/../test_helper'

unit_tests do
  test "running? is true if sending kill(0, pid) does not fail" do
    warlock = DeepTest::Warlock.new
    Process.expects(:kill).with(0, :pid)
    assert_equal true, warlock.running?(:pid)
  end
  
  test "running? is false if Process.kill(0, pid) raises Errno::ESRCH" do
    warlock = DeepTest::Warlock.new
    Process.stubs(:kill).raises(Errno::ESRCH)
    assert_equal false, warlock.running?(:pid)
  end
  
  test "running? is true if Process.kill raises Exception" do
    warlock = DeepTest::Warlock.new
    Process.stubs(:kill).raises(Exception)
    assert_equal true, warlock.running?(:pid)
  end
end
