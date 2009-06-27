require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "deploy_agents starts agents on a new agent server" do
        client = ThroughputWorkerClient.new(
          options = Options.new({}),
          landing_ship = stub_everything
        )

        landing_ship.expects(:establish_beachhead).with(options).
          returns(beachhead = stub_everything)

        beachhead.expects(:deploy_agents)
        client.deploy_agents
      end

      test "terminate_agents stops agents on agent server that was spawned in deploy_agents" do
        beachhead = stub_everything
        client = ThroughputWorkerClient.new(
          Options.new({}),
          landing_ship = stub_everything(:establish_beachhead => beachhead)
        )

        client.deploy_agents
        beachhead.expects(:terminate_agents)
        client.terminate_agents
      end
    end
  end
end
