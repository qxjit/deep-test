require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    class HeartbeatTestDemon
      include Demon
      def self.heartbeat_interval; 0.01; end
    end
    test "beeps monitor at specified interval" do
      monitor = Medic::Monitor.new HeartbeatTestDemon, 0.02
      heartbeat = Heartbeat.new monitor, 0.01

      begin
        30.times do
          Thread.pass
          sleep 0.02
          assert_equal false, monitor.fatal?
        end
      ensure
        heartbeat.stop 
      end
    end
    
    test "stop causes the heartbeat to stop deeping the monitor" do
      monitor = Medic::Monitor.new HeartbeatTestDemon, 0.02
      heartbeat = Heartbeat.new monitor, 0.01
      heartbeat.stop
      sleep 0.03
      assert_equal true, monitor.fatal?
    end
  end
end

