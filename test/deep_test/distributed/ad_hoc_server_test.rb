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
end
