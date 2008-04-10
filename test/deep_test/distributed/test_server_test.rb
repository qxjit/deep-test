require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "generates a local working copy path based on host and source of request" do
    DeepTest::Distributed::DRbClientConnectionInfo.expects(:new).
      returns(:connection_info)

    Socket.stubs(:gethostname).returns("myhost", "serverhost")
    server = DeepTest::Distributed::TestServer.new(:work_dir => "/tmp")
    options = DeepTest::Options.new(:sync_options => {:source => "/my/local/dir"})
    DeepTest::Distributed::RSync.expects(:sync).with(:connection_info,
                                                     options,
                                                     "/tmp/myhost_my_local_dir")
    server.sync(options)
  end

  test "work_dir can be set from command line" do
    config = DeepTest::Distributed::TestServer.parse_args(
      ['--work_dir','path']
    )
    assert_equal 'path', config[:work_dir]
  end

  test "uri can be set from command line" do
    config = DeepTest::Distributed::TestServer.parse_args(['--uri','uri'])
    assert_equal 'uri', config[:uri]
  end

  test "number_of_workers can be set from command line" do
    config = DeepTest::Distributed::TestServer.parse_args(
      ['--number_of_workers','4']
    )
    assert_equal 4, config[:number_of_workers]
  end

  test "default number_of_workers is 2" do
    assert_equal(
      2, 
      DeepTest::Distributed::TestServer::DEFAULT_CONFIG[:number_of_workers]
    )
  end

  test "uses default options for those not specified" do
    config = DeepTest::Distributed::TestServer.parse_args([])
    assert_equal DeepTest::Distributed::TestServer::DEFAULT_CONFIG, config
  end

  test "spawn_worker_server starts RemoteWorkerServer with TestServerWorkers" do
    config = {:number_of_workers => 4, :uri => "druby://localhost:4022"}
    server = DeepTest::Distributed::TestServer.new(config)
    options = DeepTest::Options.new(:sync_options => {:source => ""})
    DeepTest::Distributed::DRbClientConnectionInfo.expects(:new).
      returns(:connection_info)

    DeepTest::Distributed::TestServerWorkers.expects(:new).with(
      options, config, :connection_info
    ).returns(:workers)
  
    DeepTest::Distributed::RemoteWorkerServer.expects(:start).with(
      anything, :workers
    )

    server.spawn_worker_server(options)
  end

  test "connect creates dispatch controller for all servers" do
    options = DeepTest::Options.new({:ui => "DeepTest::UI::Null"})
    DRbObject.expects(:new_with_uri).returns(server = mock)
    server.expects(:servers).returns([s1 = mock, s2 = mock])
    s1.expects(:sync)
    s2.expects(:sync)
    DeepTest::Distributed::TestServer.connect(options).sync(options)
  end

  test "status.binding_uri is the uri that DRb is bound to" do
    server = DeepTest::Distributed::TestServer.new(:number_of_workers => 4)
    DRb.expects(:uri).returns("druby://test")
    assert_equal "druby://test", server.status.binding_uri
  end

  test "status.number_of_workers in the configured number of workers" do
    server = DeepTest::Distributed::TestServer.new(:number_of_workers => 4)
    DRb.expects(:uri)
    assert_equal 4, server.status.number_of_workers
  end

  test "status.remote_worker_server_count is number of servers currently running" do
    server = DeepTest::Distributed::TestServer.new(:number_of_workers => 4)
    DRb.expects(:uri)
    DeepTest::Distributed::RemoteWorkerServer.expects(:running_server_count).
      returns(3)
    assert_equal 3, server.status.remote_worker_server_count
  end
end
