module DeepTest
  module Distributed
    class ThroughputWorkerClient
      def initialize(options, mirror_server)
        @options = options
        @mirror_server = mirror_server
      end

      def start_all
        @worker_server = @mirror_server.spawn_worker_server(@options)
        @worker_server.start_all
      end

      def stop_all
        @worker_server.stop_all
      end
    end
  end
end
