module DeepTest
  module Distributed
    class ThroughputWorkerClient
      def initialize(options, landing_ship)
        @options = options
        @landing_ship = landing_ship
      end

      def start_all
        @worker_server = @landing_ship.spawn_worker_server(@options)
        @worker_server.start_all
      end

      def stop_all
        @worker_server.stop_all
      end
    end
  end
end
