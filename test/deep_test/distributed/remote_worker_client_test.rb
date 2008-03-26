require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "load_files syncs the mirror" do
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      options = DeepTest::Options.new(:sync_options => {:source => "/tmp"}),
      test_server = stub_everything(:spawn_worker_server => stub_everything)
    )

    test_server.expects(:sync).with(options)
    client.expects(:load)
    client.load_files ["filelist"]
  end

  test "load_files loads files on worker server" do
    worker_server = stub_everything
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      DeepTest::Options.new(:sync_options => {:source => "/tmp"}),
      test_server = stub_everything(:spawn_worker_server => worker_server)
    )

    worker_server.expects(:load_files).with(["filelist"])
    client.expects(:load)
    client.load_files ["filelist"]
  end

  test "load_files loads files locally" do
    worker_server = stub_everything
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      DeepTest::Options.new(:sync_options => {:source => "/tmp"}),
      test_server = stub_everything(:spawn_worker_server => worker_server)
    )

    client.expects(:load).with("filelist")
    client.load_files ["filelist"]
  end

  test "start_all starts workers on worker server" do
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      options = DeepTest::Options.new(:sync_options => {:source => "/tmp"}),
      test_server = stub_everything
    )

    test_server.expects(:spawn_worker_server).with(options).
      returns(worker_server = stub_everything)

    client.expects(:load)
    client.load_files ["filelist"]

    worker_server.expects(:start_all)
    client.start_all
  end

  test "stop_all stops workers on worker server that was spawned in load_files" do
    worker_server = stub_everything
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      DeepTest::Options.new(:sync_options => {:source => "/tmp"}),
      test_server = stub_everything(:spawn_worker_server => worker_server)
    )

    client.expects(:load)
    client.load_files ["filelist"]

    worker_server.expects(:stop_all)
    client.stop_all
  end
end
