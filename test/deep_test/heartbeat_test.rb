require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    class HeartbeatTestDemon
      include Demon
      
      attr_reader :stopped
      def self.heartbeat_interval; 0.01; end
      def heartbeat_stopped; @stopped = true; end
    end

    puts "beeps monitor at specified interval fails intermittently, skipping"
    #test "beeps monitor at specified interval" do
    #  monitor = Medic::Monitor.new HeartbeatTestDemon, 0.01
    #  heartbeat = Heartbeat.new mock, monitor, 0.02

    #  begin
    #    20.times do
    #      Thread.pass
    #      sleep 0.04
    #      Thread.pass
    #      assert_equal false, monitor.fatal?
    #    end
    #  ensure
    #    heartbeat.stop 
    #  end
    #end
    
    test "stop causes the heartbeat to stop deeping the monitor" do
      monitor = Medic::Monitor.new HeartbeatTestDemon, 0.02
      heartbeat = Heartbeat.new mock, monitor, 0.01
      heartbeat.stop
      sleep 0.03
      assert_equal true, monitor.fatal?
    end

    test "stops demon if beep fails" do
      error_monitor = mock
      error_monitor.expects(:beep).raises(Exception.new)
      demon = HeartbeatTestDemon.new
      Heartbeat.new(demon, error_monitor, 0.01).thread.join
      assert_equal true, demon.stopped
    end

    test "stops demon if beep takes more than 2 heartbeat times" do
      slow_monitor = Class.new do
        def beep; sleep 0.3; end
      end.new

      demon = HeartbeatTestDemon.new
      Heartbeat.new(demon, slow_monitor, 0.01).thread.join
      assert_equal true, demon.stopped
    end
  end
end

