require File.dirname(__FILE__) + "/../test_helper"

$last_thread_list = Thread.list

#set_trace_func proc { |event, file, line, id, binding, classname|
#  (Thread.list - $last_thread_list).each do |t|
#    puts "New thread: #{t.object_id}: #{event} #{File.basename(file)}:#{line} #{id} #{binding} #{classname}"
#  end
#  $last_thread_list = Thread.list
#}

module DeepTest
  unit_tests do
    class HeartbeatTestDemon
      include Demon
      
      attr_reader :stopped
      def self.heartbeat_interval; 0.01; end
      def heartbeat_stopped; @stopped = true; end
    end

    test "beeps monitor at specified interval" do
      monitor = Medic::Monitor.new HeartbeatTestDemon, 0.01
      heartbeat = Heartbeat.new mock, monitor, 0.02

      begin
        20.times do
          Thread.pass
          sleep 0.04
          Thread.pass
          assert_equal false, monitor.fatal?
        end
      ensure
        heartbeat.stop 
      end
    end
    
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

