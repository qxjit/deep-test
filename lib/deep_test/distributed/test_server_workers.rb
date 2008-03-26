module DeepTest
  module Distributed
    class TestServerWorkers < LocalWorkers
      def initialize(options, test_server_config)
        super(options)
        @test_server_config = test_server_config
      end
      
      def number_of_workers
        @test_server_config[:number_of_workers]
      end

      def start_all
        super
        @warlock.exit_when_none_running
      end
    end
  end
end
