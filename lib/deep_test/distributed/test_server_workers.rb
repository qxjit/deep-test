module DeepTest
  module Distributed
    class TestServerWorkers < LocalWorkers
      def initialize(options, test_server_config, connection_info)
        super(options)
        @test_server_config = test_server_config
        @connection_info = connection_info
      end
      
      def number_of_workers
        @test_server_config[:number_of_workers]
      end

      def server
        DeepTest::Server.remote_reference(@connection_info.address, @options.server_port)
      end

      def start_all
        super
        @warlock.exit_when_none_running
      end
    end
  end
end
