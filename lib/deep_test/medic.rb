module DeepTest
  class Medic
    include DRb::DRbUndumped
    attr_reader :fatal_heartbeat_padding

    def initialize(fatal_heartbeat_padding = 2)
      @fatal_heartbeat_padding = fatal_heartbeat_padding
    end

    def assign_monitor(type)
      (monitors << Monitor.new(type, fatal_heartbeat_padding)).last
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

      def initialize(type, fatal_heartbeat_padding)
        @type = type
        @fatal_heartbeat_padding = fatal_heartbeat_padding
        beep
      end

      def beep
        @last_beep = Time.now
        nil
      end

      def fatal?
        (Time.now - @last_beep) > (type.heartbeat_interval + @fatal_heartbeat_padding)
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
