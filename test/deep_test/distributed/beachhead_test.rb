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

      test "central_command is retrieved using client connection information" do
        beachhead = Beachhead.new("/tmp", options = Options.new({}), mock(:address => "address"))
        DeepTest::CentralCommand.expects(:remote_reference).
          with("address", options.server_port).returns(:central_command_reference)

        assert_equal :central_command_reference, beachhead.central_command
      end

      test "service is removed after grace period if agents haven't been started" do
        log_level = DeepTest.logger.level
        begin
          DeepTest.logger.level = Logger::ERROR
          beachhead = Beachhead.new("", Options.new({}), stub_everything)
          beachhead.stubs(:start_agent)
          beachhead.daemonize("localhost", 0.25)
          # Have to sleep long enough to warlock to reap dead process
          sleep 1.0
          assert_equal 0, Beachhead.warlock.demon_count
        ensure
          begin
            Beachhead.warlock.stop_demons
          ensure
            DeepTest.logger.level = log_level
          end
        end
      end

      test "service is not removed after grace period if agents have been started" do
        log_level = DeepTest.logger.level
        begin
          DeepTest.logger.level = Logger::ERROR
          beachhead = Beachhead.new("", Options.new({}), stub_everything)
          beachhead.stubs(:start_agent)
          # Since we're not actually starting agents, we don't want to exit when none are running for this test
          beachhead.instance_variable_get(:@warlock).stubs(:exit_when_none_running)
          remote_reference = beachhead.daemonize("localhost", 0.25)
          remote_reference.deploy_agents
          # Have to sleep long enough to warlock to reap dead process
          sleep 1.0
          assert_equal 1, Beachhead.warlock.demon_count
        ensure
          begin
            Beachhead.warlock.stop_demons
          ensure
            DeepTest.logger.level = log_level
          end
        end
      end
    end
  end
end
