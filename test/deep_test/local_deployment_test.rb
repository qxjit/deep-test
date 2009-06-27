require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "number_of_agents is determined by options" do
      deployment = LocalDeployment.new(
        Options.new(:number_of_agents => 4)
      )

      assert_equal 4, deployment.number_of_agents
    end

    test "load_files simply loads each file provided" do
      deployment = LocalDeployment.new(
        Options.new(:number_of_agents => 4)
      )

      deployment.expects(:load).with(:file_1)
      deployment.expects(:load).with(:file_2)

      deployment.load_files([:file_1, :file_2])
    end

    test "start_all redirects stdout and stderr back to central_command" do
      agent_class = Class.new do
        def initialize(agent_num, central_command, listeners);  end
        def run; puts "hello stdout"; $stderr.puts "hello stderr" end
      end

      central_command = stub :stdout => StringIO.new, :stderr => StringIO.new

      with_drb_server_for central_command do |drb_server|
        options = stub :number_of_agents => 1, 
                       :central_command => DRbObject.new_with_uri(drb_server.uri),
                       :new_listener_list => []

        run_agents_to_completion LocalDeployment.new(options, agent_class)
      end

      assert_equal "hello stdout\n", central_command.stdout.string
      assert_equal "hello stderr\n", central_command.stderr.string
    end

    def with_drb_server_for(front)
      # using drbunix prevents a getaddrinfo on our host, which can take 5 seconds
      drb_server = DRb::DRbServer.new "drbunix:", front

      begin
        yield drb_server
      ensure
        drb_server.stop_service
      end
    end

    def run_agents_to_completion(deployment)
      deployment.start_all
      deployment.wait_for_completion
    ensure
      deployment.stop_all
    end
  end
end
