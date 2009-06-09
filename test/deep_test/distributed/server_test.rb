require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "generates a local working copy path based on host and source of request" do
        Socket.stubs(:gethostname).returns("myhost")
        server = Server.new(:address => "host", :work_dir => "/tmp")
        options = Options.new(:sync_options => {:source => "/my/local/dir"})
        RSync.expects(:push).with("host", options, "/tmp/myhost_my_local_dir")
        server.sync(options)
      end
      
      test "new_dispatch_controller creates dispatch controller for all servers" do
        Socket.stubs(:gethostname).returns("myhost")
        options = Options.new(:ui => "DeepTest::UI::Null",
                              :sync_options => {:source => "/my/local/dir"},
                              :distributed_hosts => %w[server1 server2])

        RSync.expects(:push).with("server1", options, "/tmp/myhost_my_local_dir")
        RSync.expects(:push).with("server2", options, "/tmp/myhost_my_local_dir")

        Server.new_dispatch_controller(options).sync(options)
      end

      test "spawn_worker_server launches worker server on remote machine" do
        Socket.stubs(:gethostname).returns("myhost")
        server = Server.new(:address => "remote_host", :work_dir => "/tmp")
        options = Options.new(:sync_options => {:source => "/my/local/dir"})

        server.expects(:`).with(
          "ssh -4 remote_host " + 
          "'#{ShellEnvironment.like_login} && cd /tmp/myhost_my_local_dir && " + 
          "rake deep_test:start_distributed_server " + 
          "OPTIONS=#{options.to_command_line} HOST=remote_host'"
        ).returns("blah blah\nRemoteWorkerServer url: druby://remote_host:9999\nblah")

        worker_server = server.spawn_worker_server(options)
        assert_equal "druby://remote_host:9999", worker_server.__drburi
      end

      test "spawn_worker_server launches worker server on remote machine with usernames specified in sync_options" do
        Socket.stubs(:gethostname).returns("myhost")
        server = Server.new(:address => "remote_host", :work_dir => "/tmp")
        options = Options.new(:sync_options => {:username => "me", 
                                                :source => "/my/local/dir"})

        server.expects(:`).with(
          "ssh -4 remote_host -l me " + 
          "'#{ShellEnvironment.like_login} && cd /tmp/myhost_my_local_dir && " + 
          "rake deep_test:start_distributed_server " + 
          "OPTIONS=#{options.to_command_line} HOST=remote_host'"
        ).returns("blah blah\nRemoteWorkerServer url: druby://remote_host:9999\nblah")

        server.spawn_worker_server(options)
      end
    end
  end
end
