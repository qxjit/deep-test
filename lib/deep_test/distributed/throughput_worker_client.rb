module DeepTest
  module Distributed
    class ThroughputWorkerClient
      def initialize(options, landing_ship)
        @options = options
        @landing_ship = landing_ship
      end

      def start_all
        @beachhead = @landing_ship.establish_beachhead(@options)
        @beachhead.start_all
      end

      def stop_all
        @beachhead.stop_all
      end
    end
  end
end
