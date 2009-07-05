module DeepTest
  class Heartbeat
    class <<self; alias start new; end

    def initialize(monitor, beat_interval)
      @thread = Thread.new do
        loop do
          sleep beat_interval
          monitor.beep
        end
      end
    end

    def stop
      @thread.kill
    end
  end
end
