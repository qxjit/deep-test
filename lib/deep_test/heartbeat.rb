module DeepTest
  class Heartbeat
    class <<self; alias start new; end
    attr_reader :thread

    def initialize(demon, monitor, beat_interval)
      @thread = Thread.new do
        loop do
          sleep beat_interval
          begin
            break if @stopped
            Timeout.timeout(beat_interval * 2) { monitor.beep }
          rescue Exception => e
            break
          end
        end
        demon.heartbeat_stopped
      end
    end

    def stop
      @stopped = true
    end
  end
end
