module DeepTest
  module Distributed
    class RemoteWorkerClient
      def initialize(options, test_server)
        @options = options
        @test_server = test_server
      end

      def load_files(filelist)
        @test_server.sync(@options)
        @worker_server = @test_server.spawn_worker_server(@options)
        t = Thread.new {@worker_server.load_files filelist}
        filelist.each {|f| load f}
        t.join
      end

      def start_all
        @worker_server.start_all
      end

      def stop_all
        @worker_server.stop_all
      end
    end
  end
end
