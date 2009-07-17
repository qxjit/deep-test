require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "load_files loads each file in list, resolving each filename with resolver" do
        FilenameResolver.expects(:new).with("/mirror/dir").returns(resolver = mock)

        beachhead = Beachhead.new("/mirror/dir", Options.new({}), stub_everything)

        resolver.expects(:resolve).with("/source/path/my/file.rb").returns("/mirror/dir/my/file.rb")
        beachhead.expects(:load).with("/mirror/dir/my/file.rb")
        Dir.expects(:chdir).with("/mirror/dir")

        beachhead.load_files(["/source/path/my/file.rb"])
      end

      test "load_files returns nil so nothing is sent back over DRb" do
        beachhead = Beachhead.new("/mirror/dir", Options.new({}), stub_everything)
        beachhead.expects(:load)
        FilenameResolver.any_instance.expects(:resolve)
        Dir.expects(:chdir)

        assert_equal nil, beachhead.load_files(["/source/path/my/file.rb"])
      end

      test "central_command is retrieved using client connection information" do
        beachhead = Beachhead.new("/tmp", options = Options.new({}), mock(:address => "address"))
        DeepTest::CentralCommand.expects(:remote_reference).
          with("address", options.server_port).returns(:central_command_reference)

        assert_equal :central_command_reference, beachhead.central_command
      end

      test "deploy_agents returns nil so nothing is serialized over DRb" do
        central_command = FakeCentralCommand.new
        beachhead = Beachhead.new "", Options.new(:number_of_agents => 0, :server_port => central_command.port), stub(:address => "localhost")
        # Since we're not actually starting agents, we don't want to exit when none are running for this test
        beachhead.warlock.stubs(:exit_when_none_running).returns(:not_nil)
        assert_equal nil, beachhead.deploy_agents
      end

      test "wait_for_heartbeat_to_stop returns once the heartbeat stops" do
        beachhead = Beachhead.new "", Options.new({}), stub
        t = Thread.new { beachhead.wait_for_heartbeat_to_stop }
        Thread.pass
        beachhead.heartbeat_stopped
        t.join
      end

      test "service is removed after grace period if agents have not been started" do
        options = Options.new({:number_of_agents => 0})
        central_command = TestCentralCommand.start(options)
        begin
          beachhead = Beachhead.new "", options, stub(:address => "localhost")
          beachhead.daemonize("localhost", 0.25)
          # Have to sleep long enough to warlock to reap dead process
          sleep 1.0
          assert_equal 0, beachhead.warlock.demon_count
        ensure
          beachhead.warlock.stop_demons
        end
      end

      test "service is not removed after grace period if agents have been started" do
        options = Options.new({:number_of_agents => 0})
        central_command = TestCentralCommand.start(options)
        begin
          beachhead = Beachhead.new "", options, stub(:address => "localhost")
          # Since we're not actually starting agents, we don't want to exit when none are running for this test
          beachhead.warlock.stubs(:exit_when_none_running)
          remote_reference = beachhead.daemonize("localhost", 0.25)
          remote_reference.deploy_agents
          # Have to sleep long enough to warlock to reap dead process
          sleep 1.0
          assert_equal 1, beachhead.warlock.demon_count
        ensure
          beachhead.warlock.stop_demons
        end
      end
    end
  end
end
