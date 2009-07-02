module DeepTest
  class Heartbeat
    INTERVAL = 3 unless defined?(INTERVAL)
    def initialize(monitor, beat_interval = INTERVAL)
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
