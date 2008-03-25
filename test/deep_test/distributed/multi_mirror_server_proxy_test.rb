require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "sync is invoked on all servers" do
    server_1, server_2 = mock, mock
    options = DeepTest::Options.new({:ui => "DeepTest::UI::Null"})

    master = DeepTest::Distributed::MultiMirrorServerProxy.new(options, [server_1, server_2])

    server_1.expects(:sync).with(options)
    server_2.expects(:sync).with(options)

    master.sync(options)
  end

  test "spawn_worker_server is invoked on all server" do
    server_1, server_2 = mock, mock
    options = DeepTest::Options.new({:ui => "DeepTest::UI::Null"})

    master = DeepTest::Distributed::MultiMirrorServerProxy.new(options, [server_1, server_2])

    server_1.expects(:spawn_worker_server).with(options)
    server_2.expects(:spawn_worker_server).with(options)

    master.spawn_worker_server(options)
  end

  test "spawn_worker_server returns WorkerServerProxy with each worker" do
    server_1 = mock(:spawn_worker_server => :worker_server_1)
    server_2 = mock(:spawn_worker_server => :worker_server_2)
    options = DeepTest::Options.new({:ui => "DeepTest::UI::Null"})

    master = DeepTest::Distributed::MultiMirrorServerProxy.new(options, [server_1, server_2])

    DeepTest::Distributed::MultiMirrorServerProxy::WorkerServerProxy.
      expects(:new).with(options, [:worker_server_1, :worker_server_2])

    master.spawn_worker_server(options)
  end

  test "WorkerServerProxy dispatches start_all" do
    server_1, server_2 = mock, mock

    master = DeepTest::Distributed::MultiMirrorServerProxy::WorkerServerProxy.new(
      DeepTest::Options.new({:ui => "DeepTest::UI::Null"}),
      [server_1, server_2]
    )

    server_1.expects(:start_all)
    server_2.expects(:start_all)

    master.start_all
  end

  test "WorkerServerProxy dispatches stop_all" do
    server_1, server_2 = mock, mock

    master = DeepTest::Distributed::MultiMirrorServerProxy::WorkerServerProxy.new(
      DeepTest::Options.new({:ui => "DeepTest::UI::Null"}),
      [server_1, server_2]
    )

    server_1.expects(:stop_all)
    server_2.expects(:stop_all)

    master.stop_all
  end

  test "WorkerServerProxy dispatches load_files" do
    server_1, server_2 = mock, mock

    master = DeepTest::Distributed::MultiMirrorServerProxy::WorkerServerProxy.new(
      DeepTest::Options.new({:ui => "DeepTest::UI::Null"}),
      [server_1, server_2]
    )

    server_1.expects(:load_files).with(:filelist)
    server_2.expects(:load_files).with(:filelist)

    master.load_files :filelist
  end
end
