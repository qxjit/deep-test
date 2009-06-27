require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "deploy_agents delegates to agent implementation" do
        beachhead = Beachhead.new("", implementation = mock)
        implementation.expects(:deploy_agents)
        beachhead.deploy_agents
      end

      test "terminate_agents delegates to agent implementation" do
        beachhead = Beachhead.new("", implementation = mock)
        implementation.expects(:terminate_agents)
        beachhead.terminate_agents.join
      end

      test "terminate_agents returns without waiting for stops" do
        implementation = Object.new.instance_eval do
          def done?
            @done == true
          end

          def terminate_agents
            sleep 0.01
            @done = true
          end
          self
        end

        beachhead = Beachhead.new("", implementation)
        beachhead.terminate_agents
        assert_equal false, implementation.done?

        until implementation.done?
          sleep 0.01
        end
      end
      
      test "load_files loads each file in list, resolving each filename with resolver" do
        FilenameResolver.expects(:new).with("/mirror/dir").
          returns(resolver = mock)

        beachhead = Beachhead.new("/mirror/dir", stub_everything)

        resolver.expects(:resolve).with("/source/path/my/file.rb").
          returns("/mirror/dir/my/file.rb")
        beachhead.expects(:load).with("/mirror/dir/my/file.rb")
        Dir.expects(:chdir).with("/mirror/dir")

        beachhead.load_files(["/source/path/my/file.rb"])
      end

      test "service is removed after grace period if agents haven't been started" do
        log_level = DeepTest.logger.level
        begin
          DeepTest.logger.level = Logger::ERROR
          Beachhead.start(
            "localhost",
            "base_path",
            stub_everything,
            0.25
          )
          # Have to sleep long enough to warlock to reap dead process
          sleep 1.0
          assert_equal 0, Beachhead.running_server_count
        ensure
          begin
            Beachhead.terminate_agents
          ensure
            DeepTest.logger.level = log_level
          end
        end
      end

      test "service is not removed after grace period if agents have been started" do
        log_level = DeepTest.logger.level
        begin
          DeepTest.logger.level = Logger::ERROR
          beachhead = nil
          capture_stdout do
            beachhead = Beachhead.start(
              "localhost",
              "", 
              stub_everything,
              0.25
            )
          end
          beachhead.deploy_agents
          # Have to sleep long enough to warlock to reap dead process
          sleep 1.0
          assert_equal 1, Beachhead.running_server_count
        ensure
          begin
            Beachhead.terminate_agents
          ensure
            DeepTest.logger.level = log_level
          end
        end
      end
    end
  end
end
