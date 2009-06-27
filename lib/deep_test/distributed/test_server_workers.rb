module DeepTest
  module Distributed
    class TestServerWorkers < LocalDeployment
      def initialize(options, test_server_config, connection_info)
        super(options)
        @test_server_config = test_server_config
        @connection_info = connection_info
      end
      
      def number_of_agents
        @test_server_config[:number_of_agents]
      end

      def central_command
        DeepTest::CentralCommand.remote_reference(@connection_info.address, 
                                                  @options.server_port)
      end

      def deploy_agents
        super
        @warlock.exit_when_none_running
      end
    end
  end
end
