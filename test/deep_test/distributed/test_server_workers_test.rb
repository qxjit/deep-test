require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "number_of_agents is determined by mirror server options" do
        agents = TestServerWorkers.new(
          Options.new({}), {:number_of_agents => 4}, mock
        )

        assert_equal 4, agents.number_of_agents
      end

      test "central_command is retrieved using client connection information" do
        agents = TestServerWorkers.new(
          options = Options.new({}),
          {:number_of_agents => 4},
          mock(:address => "address")
        )
        DeepTest::CentralCommand.expects(:remote_reference).
          with("address", options.server_port).returns(:central_command_reference)

        assert_equal :central_command_reference, agents.central_command
      end
    end
  end
end
