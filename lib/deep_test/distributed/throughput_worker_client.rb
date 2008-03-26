module DeepTest
  module Distributed
    class ThroughputWorkerClient
      def initialize(options, test_server)
        @options = options
        @test_server = test_server
      end

      def start_all
        @worker_server = @test_server.spawn_worker_server(@options)
        @worker_server.start_all
      end

      def stop_all
        @worker_server.stop_all
      end
    end
  end
end
