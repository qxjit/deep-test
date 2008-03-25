require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "generates a local working copy path based on host and source of request" do
    Socket.stubs(:gethostname).returns("myhost")
    server = DeepTest::Distributed::MirrorServer.new(:mirror_base_path => "/tmp")
    options = DeepTest::Options.new(:sync_options => {:source => "/my/local/dir"})
    DeepTest::Distributed::RSync.expects(:sync).with(options,
                                                     "/tmp/myhost_my_local_dir")
    server.sync(options)
  end

  test "mirror_base_path can be set from command line" do
    config = DeepTest::Distributed::MirrorServer.parse_args(
      ['--mirror_base_path','path']
    )
    assert_equal 'path', config[:mirror_base_path]
  end

  test "uri can be set from command line" do
    config = DeepTest::Distributed::MirrorServer.parse_args(['--uri','uri'])
    assert_equal 'uri', config[:uri]
  end

  test "number_of_workers can be set from command line" do
    config = DeepTest::Distributed::MirrorServer.parse_args(
      ['--number_of_workers','4']
    )
    assert_equal 4, config[:number_of_workers]
  end

  test "default number_of_workers is 2" do
    assert_equal(
      2, 
      DeepTest::Distributed::MirrorServer::DEFAULT_CONFIG[:number_of_workers]
    )
  end

  test "uses default options for those not specified" do
    config = DeepTest::Distributed::MirrorServer.parse_args([])
    assert_equal DeepTest::Distributed::MirrorServer::DEFAULT_CONFIG, config
  end

  test "spawn_worker_server starts RemoteWorkerServer with MirrorServerWorkers" do
    server = DeepTest::Distributed::MirrorServer.new(:number_of_workers => 4)

    options = DeepTest::Options.new(:sync_options => {:source => ""})
    DeepTest::Distributed::MirrorServerWorkers.expects(:new).with(
      options,
      {:number_of_workers => 4}
    ).returns(:workers)
  
    DeepTest::Distributed::RemoteWorkerServer.expects(:start).with(
      anything, anything, :workers
    )

    server.spawn_worker_server(options)
  end

  test "connect creates dispatch controller for all servers" do
    options = DeepTest::Options.new({:ui => "DeepTest::UI::Null"})
    DRbObject.expects(:new_with_uri).returns(server = mock)
    server.expects(:servers).returns([s1 = mock, s2 = mock])
    s1.expects(:sync)
    s2.expects(:sync)
    DeepTest::Distributed::MirrorServer.connect(options).sync(options)
  end

  test "status.binding_uri is the uri that DRb is bound to" do
    server = DeepTest::Distributed::MirrorServer.new(:number_of_workers => 4)
    DRb.expects(:uri).returns("druby://test")
    assert_equal "druby://test", server.status.binding_uri
  end

  test "status.number_of_workers in the configured number of workers" do
    server = DeepTest::Distributed::MirrorServer.new(:number_of_workers => 4)
    DRb.expects(:uri)
    assert_equal 4, server.status.number_of_workers
  end

  test "status.remote_worker_server_count is number of servers currently running" do
    server = DeepTest::Distributed::MirrorServer.new(:number_of_workers => 4)
    DRb.expects(:uri)
    DeepTest::Distributed::RemoteWorkerServer.expects(:running_server_count).
      returns(3)
    assert_equal 3, server.status.remote_worker_server_count
  end
end
