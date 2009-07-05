require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "number_of_agents is determined by options" do
      deployment = LocalDeployment.new Options.new(:number_of_agents => 4)
      assert_equal 4, deployment.number_of_agents
    end

    test "load_files simply loads each file provided" do
      deployment = LocalDeployment.new Options.new({})

      deployment.expects(:load).with(:file_1)
      deployment.expects(:load).with(:file_2)

      deployment.load_files([:file_1, :file_2])
    end

    class DieWithoutStartingHeartbeatAgent < Agent
      def self.heartbeat_interval; 0.05; end
      def forked(*args)
        exit(0)
      end
    end

    test "deploy_agents tells Medic to expect live Agents" do
      deployment = LocalDeployment.new Options.new(:number_of_agents => 1), DieWithoutStartingHeartbeatAgent
      central_command = FakeCentralCommand.new
      central_command.with_drb_server do |remote_reference|
        deployment.stubs(:central_command => remote_reference)
        deployment.deploy_agents
        3.times do
          sleep DieWithoutStartingHeartbeatAgent.heartbeat_interval + central_command.medic.fatal_heartbeat_padding
          assert_equal true, central_command.medic.triage(DieWithoutStartingHeartbeatAgent).fatal?
        end
      end
    end
  end
end
