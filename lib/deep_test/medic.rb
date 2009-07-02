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

      def initialize(type)
        @type = type
        beep
      end

      def beep
        @last_beep = Time.now
        nil
      end

      def fatal?
        (Time.now - @last_beep) > 5
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
