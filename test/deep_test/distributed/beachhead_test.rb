require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "load_files loads each file in list, resolving each filename with resolver" do
        FilenameResolver.expects(:new).with("/mirror/dir").returns(resolver = mock)

        beachhead = Beachhead.new "/mirror/dir", Options.new({})

        resolver.expects(:resolve).with("/source/path/my/file.rb").returns("/mirror/dir/my/file.rb")
        beachhead.expects(:load).with("/mirror/dir/my/file.rb")
        Dir.expects(:chdir).with("/mirror/dir")

        beachhead.load_files(["/source/path/my/file.rb"])
      end

      test "service is removed after grace period if agents have not been started" do
        options = Options.new({:number_of_agents => 0})
        TestCentralCommand.start options
        begin
          beachhead = Beachhead.new "", options
          beachhead.daemonize(0.25)
          # Have to sleep long enough to warlock to reap dead process
          sleep 2.0
          assert_equal 0, beachhead.warlock.demon_count
        ensure
          beachhead.warlock.stop_demons
        end
      end

      test "service is not removed after grace period if agents have been started" do
        options = Options.new({:number_of_agents => 0})
        TestCentralCommand.start options
        begin
          beachhead = Beachhead.new "", options
          # Since we're not actually starting agents, we don't want to exit when none are running for this test
          beachhead.warlock.stubs(:exit_when_none_running)
          port = beachhead.daemonize(0.25)
          Telegraph::Wire.connect("localhost", port).send_message Beachhead::DeployAgents
          # Have to sleep long enough to warlock to reap dead process
          sleep 1.0
          assert_equal 1, beachhead.warlock.demon_count
        ensure
          beachhead.warlock.stop_demons
        end
      end

      test "responds with Done after receiving LoadFiles and DeployAgents" do
        options = Options.new({:number_of_agents => 0})
        TestCentralCommand.start options
        begin
          beachhead = Beachhead.new File.dirname(__FILE__), options
          # Since we're not actually starting agents, we don't want to exit when none are running for this test
          beachhead.warlock.stubs(:exit_when_none_running)
          port = beachhead.daemonize(0.25)
          wire = Telegraph::Wire.connect("localhost", port)
          wire.send_message Beachhead::LoadFiles.new([])
          wire.send_message Beachhead::DeployAgents
          assert_equal Beachhead::Done, wire.next_message(:timeout => 1)
        ensure
          beachhead.warlock.stop_demons
        end
      end
    end
  end
end
