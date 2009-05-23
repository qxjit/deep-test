require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "generates a local working copy path based on host and source of request" do
    Socket.stubs(:gethostname).returns("myhost")
    server = DeepTest::Distributed::AdHocServer.new(:address => "host",
                                                    :work_dir => "/tmp")
    options = DeepTest::Options.new(:sync_options => {:source => "/my/local/dir"})
    DeepTest::Distributed::RSync.expects(:push).with("host",
                                                     options,
                                                     "/tmp/myhost_my_local_dir")
    server.sync(options)
  end
  
  test "new_dispatch_controller creates dispatch controller for all servers" do
    Socket.stubs(:gethostname).returns("myhost")
    options = DeepTest::Options.new(:ui => "DeepTest::UI::Null",
                                    :sync_options => {:source => "/my/local/dir"},
                                    :adhoc_distributed_hosts => "server1 server2")

    DeepTest::Distributed::RSync.expects(:push).with("server1",
                                                     options,
                                                     "/tmp/myhost_my_local_dir")
    DeepTest::Distributed::RSync.expects(:push).with("server2",
                                                     options,
                                                     "/tmp/myhost_my_local_dir")

    DeepTest::Distributed::AdHocServer.new_dispatch_controller(options).
      sync(options)
  end

  test "spawn_worker_server launches worker server on remote machine" do
    Socket.stubs(:gethostname).returns("myhost")
    server = DeepTest::Distributed::AdHocServer.new(:address => "host",
                                                    :work_dir => "/tmp")
    options = DeepTest::Options.new(:sync_options => {:source => "/my/local/dir"})

    server.expects(:`).with(
      "ssh -4 host 'cd /tmp/myhost_my_local_dir && " + 
      "rake start_ad_hoc_deep_test_server OPTIONS=#{options.to_command_line}'"
    ).returns("blah blah\nRemoteWorkerServer url: druby://host:9999\nblah")

    worker_server = server.spawn_worker_server(options)
    assert_equal "druby://host:9999", worker_server.__drburi
  end
end
