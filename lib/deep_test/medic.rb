module DeepTest
  class Medic
    def assign_monitor(type)
      (monitors << Monitor.new(type)).last
    end

    def monitors
      @monitors ||= []
    end

    def triage(type)
      Triage.new monitors.select {|m| m.type == type}
    end

    class Monitor
      include DRb::DRbUndumped

      attr_reader :type

      def initialize(type, fatal_heartbeat_interval = (Heartbeat::INTERVAL + 2))
        @type = type
        @fatal_heartbeat_interval = fatal_heartbeat_interval
        beep
      end

      def beep
        @last_beep = Time.now
        nil
      end

      def fatal?
        (Time.now - @last_beep) > @fatal_heartbeat_interval
      end
    end

    class Triage
      def initialize(monitors)
        @monitors = monitors
      end

      def fatal?
        @monitors.all? {|m| m.fatal?}
      end
    end
  end
end
