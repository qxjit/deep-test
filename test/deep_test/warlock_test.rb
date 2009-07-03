require File.dirname(__FILE__) + '/../test_helper'

module DeepTest
  unit_tests do
    test "running? is true if sending kill(0, pid) does not fail" do
      warlock = Warlock.new mock
      Process.expects(:kill).with(0, :pid)
      assert_equal true, warlock.running?(:pid)
    end
    
    test "running? is false if Process.kill(0, pid) raises Errno::ESRCH" do
      warlock = Warlock.new mock
      Process.stubs(:kill).raises(Errno::ESRCH)
      assert_equal false, warlock.running?(:pid)
    end
    
    test "running? is true if Process.kill raises Exception" do
      warlock = Warlock.new mock
      Process.stubs(:kill).raises(Exception)
      assert_equal true, warlock.running?(:pid)
    end

    test "demon_count is 0 initially" do
      assert_equal 0, Warlock.new(mock).demon_count
    end

    test "add_demon increases demon_count by 1" do
      warlock = Warlock.new mock
      warlock.send(:add_demon, "name", 1)
      assert_equal 1, warlock.demon_count
    end

    test "remove_demon increases demon_count by 1" do
      warlock = Warlock.new mock
      warlock.send(:add_demon, "name", 1)
      warlock.send(:remove_demon, "name", 1)
      assert_equal 0, warlock.demon_count
    end
  end
end
