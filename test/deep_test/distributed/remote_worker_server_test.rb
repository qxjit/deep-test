require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "start_all delegates to worker implementation" do
        server = RemoteWorkerServer.new("", implementation = mock)
        implementation.expects(:start_all)
        server.start_all
      end

      test "stop_all delegates to worker implementation" do
        server = RemoteWorkerServer.new("", implementation = mock)
        implementation.expects(:stop_all)
        server.stop_all
      end

      test "stop_all returns without waiting for stops" do
        implementation = Object.new.instance_eval do
          def done?
            @done == true
          end

          def stop_all
            sleep 0.01
            @done = true
          end
          self
        end

        server = RemoteWorkerServer.new("", implementation)
        server.stop_all
        assert_equal false, implementation.done?

        until implementation.done?
          sleep 0.01
        end
      end
      
      test "load_files loads each file in list, resolving each filename with resolver" do
        FilenameResolver.expects(:new).with("/mirror/dir").
          returns(resolver = mock)

        server = RemoteWorkerServer.new("/mirror/dir", stub_everything)

        resolver.expects(:resolve).with("/source/path/my/file.rb").
          returns("/mirror/dir/my/file.rb")
        server.expects(:load).with("/mirror/dir/my/file.rb")
        Dir.expects(:chdir).with("/mirror/dir")

        server.load_files(["/source/path/my/file.rb"])
      end

      test "service is removed after grace period if workers haven't been started" do
        log_level = DeepTest.logger.level
        begin
          DeepTest.logger.level = Logger::ERROR
          RemoteWorkerServer.start(
            "localhost",
            "base_path",
            stub_everything,
            0.25
          )
          # Have to sleep long enough to warlock to reap dead process
          sleep 1.0
          assert_equal 0, RemoteWorkerServer.running_server_count
        ensure
          begin
            RemoteWorkerServer.stop_all
          ensure
            DeepTest.logger.level = log_level
          end
        end
      end

      test "service is not removed after grace period if workers have been started" do
        log_level = DeepTest.logger.level
        begin
          DeepTest.logger.level = Logger::ERROR
          server = nil
          capture_stdout do
            server = RemoteWorkerServer.start(
              "localhost",
              "", 
              stub_everything,
              0.25
            )
          end
          server.start_all
          # Have to sleep long enough to warlock to reap dead process
          sleep 1.0
          assert_equal 1, RemoteWorkerServer.running_server_count
        ensure
          begin
            RemoteWorkerServer.stop_all
          ensure
            DeepTest.logger.level = log_level
          end
        end
      end
    end
  end
end
