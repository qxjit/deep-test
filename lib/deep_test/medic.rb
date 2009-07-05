module DeepTest
  class Medic
    include DRb::DRbUndumped
    attr_reader :fatal_heartbeat_padding

    def initialize(fatal_heartbeat_padding = 2)
      @fatal_heartbeat_padding = fatal_heartbeat_padding
      @expect_live = false
    end

    def expect_live_monitors(type)
      expected_live_monitors[type] = Time.now
    end

    def assign_monitor(type)
      (monitors << Monitor.new(type, fatal_heartbeat_padding)).last
    end

    def monitors
      @monitors ||= []
    end

    def triage(type)
      Triage.new type, expected_live_monitors[type], @fatal_heartbeat_padding, monitors.select {|m| m.type == type}
    end

    private

    def expected_live_monitors
      @expect_live_monitors ||= {}
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
        type.is_lack_of_heartbeat_fatal? @last_beep, @fatal_heartbeat_padding
      end
    end

    class Triage
      def initialize(type, expected_live_time, fatal_heartbeat_padding, monitors)
        @type = type
        @expected_live_time = expected_live_time
        @monitors = monitors
        @fatal_heartbeat_padding = fatal_heartbeat_padding
      end

      def fatal?
        if @monitors.empty? && @expected_live_time
          @type.is_lack_of_heartbeat_fatal? @expected_live_time, @fatal_heartbeat_padding
        else
          @monitors.any? && @monitors.all? {|m| m.fatal?}
        end
      end
    end
  end
end
