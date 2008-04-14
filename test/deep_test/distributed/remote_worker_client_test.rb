require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "load_files broadcasts before_sync" do
    class FakeListener; end
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      options = DeepTest::Options.new(:worker_listener => FakeListener,
                                      :sync_options => {:source => "/tmp"}),
      test_server = stub_everything(:spawn_worker_server => stub_everything),
      failover_workers = mock
    )
    FakeListener.any_instance.expects(:before_sync)
    client.expects(:load)
    client.load_files ["filelist"]

  end

  test "load_files syncs the mirror" do
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      options = DeepTest::Options.new(:sync_options => {:source => "/tmp"}),
      test_server = stub_everything(:spawn_worker_server => stub_everything),
      failover_workers = mock
    )

    test_server.expects(:sync).with(options)
    client.expects(:load)
    client.load_files ["filelist"]
  end

  test "load_files loads files on worker server" do
    worker_server = stub_everything
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      DeepTest::Options.new(:sync_options => {:source => "/tmp"}),
      test_server = stub_everything(:spawn_worker_server => worker_server),
      failover_workers = mock
    )

    worker_server.expects(:load_files).with(["filelist"])
    client.expects(:load)
    client.load_files ["filelist"]
  end

  test "load_files loads files locally" do
    worker_server = stub_everything
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      DeepTest::Options.new(:sync_options => {:source => "/tmp"}),
      test_server = stub_everything(:spawn_worker_server => worker_server),
      failover_workers = mock
    )

    client.expects(:load).with("filelist")
    client.load_files ["filelist"]
  end

  test "start_all starts workers on worker server" do
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      options = DeepTest::Options.new(:sync_options => {:source => "/tmp"}),
      test_server = stub_everything,
      failover_workers = mock
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
      test_server = stub_everything(:spawn_worker_server => worker_server),
      failover_workers = mock
    )

    client.expects(:load)
    client.load_files ["filelist"]

    worker_server.expects(:stop_all)
    client.stop_all
  end

  test "exception in start_all causes failover to failover_workers" do
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      options = DeepTest::Options.new(:sync_options => {:source => "/tmp"}, :ui => DeepTest::UI::Null),
      test_server = stub_everything,
      failover_workers = mock
    )

    test_server.expects(:spawn_worker_server).with(options).
      returns(worker_server = mock)

    worker_server.expects(:load_files)
    client.expects(:load)
    client.load_files ["filelist"]

    worker_server.expects(:start_all).raises("An Error")

    failover_workers.expects(:start_all)
    client.start_all

    failover_workers.expects(:stop_all)
    client.stop_all
  end

  test "exception in sync causes failover to failover_workers" do
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      options = DeepTest::Options.new(:sync_options => {:source => "/tmp"}, :ui => DeepTest::UI::Null),
      test_server = mock,
      failover_workers = mock
    )

    test_server.expects(:sync).raises("An Error")

    client.expects(:load)
    client.load_files ["filelist"]

    failover_workers.expects(:start_all)
    client.start_all

    failover_workers.expects(:stop_all)
    client.stop_all
  end

  test "exception in load_files causes failover to failover_workers" do
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      options = DeepTest::Options.new(:sync_options => {:source => "/tmp"}, :ui => DeepTest::UI::Null),
      test_server = stub_everything,
      failover_workers = mock
    )

    test_server.expects(:spawn_worker_server).with(options).
      returns(worker_server = Object.new)

    worker_server.instance_eval do
      def calls() @calls ||= []; end
      def method_missing(sym, *args) calls << sym; end
      def load_files(filelist) raise "An Error"; end
    end

    client.expects(:load)
    client.load_files ["filelist"]

    failover_workers.expects(:start_all)
    client.start_all

    failover_workers.expects(:stop_all)
    client.stop_all

    assert_equal [], worker_server.calls
  end

  test "exception from start_all of failover_workers is raised" do
    client = DeepTest::Distributed::RemoteWorkerClient.new(
      options = DeepTest::Options.new(:sync_options => {:source => "/tmp"}, :ui => DeepTest::UI::Null),
      test_server = stub_everything,
      failover_workers = mock
    )

    test_server.expects(:spawn_worker_server).with(options).
      returns(worker_server = mock)

    worker_server.expects(:load_files).raises("An Error")
    client.expects(:load)
    client.load_files ["filelist"]

    failover_workers.expects(:start_all).raises("Failover Error").then.returns(nil)

    begin 
      client.start_all
      flunk
    rescue RuntimeError => e
      assert_equal "Failover Error", e.message
    end
  end
end
