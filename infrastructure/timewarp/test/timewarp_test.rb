$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'test/unit'
require 'timewarp'
require 'rubygems'
require 'shoulda'

class TimewarpTest < Test::Unit::TestCase
  context "control_timeline" do
    should "yield" do
      assert_equal :foo, Timewarp.control_timeline(proc {}) {:foo}
    end
    
    should "repeatedly call supplied proc every time Time.now is called" do
      time_values = [:timepoint_1, :timepoint_2]
      Timewarp.control_timeline(proc {time_values.shift}) do
        assert_equal :timepoint_1, Time.now
        assert_equal :timepoint_2, Time.now
        assert_equal nil, Time.now
      end
    end

    should "restorte the normal flow of time even if exception occurs" do
      Timewarp.control_timeline(proc {}) {raise "error"} rescue nil
      time_1 = Time.now
      sleep 0.01
      time_2 = Time.now

      assert time_1 < time_2
    end
  end

  context "freeze" do
    should "yield" do
      assert_equal :foo, Timewarp.freeze(:frozen_time) {:foo}
    end

    should "return a constant time" do
      assert_equal :frozen_time, Timewarp.freeze(:frozen_time) {Time.now}
    end

    should "parse the time if it is a string" do
      assert_equal Time.parse("2009-07-01 12:01:01"), Timewarp.freeze("2009-07-01 12:01:01") {Time.now}
    end
  end
end
