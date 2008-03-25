require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "start_all starts workers on a new worker server" do
    client = DeepTest::Distributed::ThroughputWorkerClient.new(
      options = DeepTest::Options.new({}),
      mirror_server = stub_everything
    )

    mirror_server.expects(:spawn_worker_server).with(options).
      returns(worker_server = stub_everything)

    worker_server.expects(:start_all)
    client.start_all
  end

  test "stop_all stops workers on worker server that was spawned in start_all" do
    worker_server = stub_everything
    client = DeepTest::Distributed::ThroughputWorkerClient.new(
      DeepTest::Options.new({}),
      mirror_server = stub_everything(:spawn_worker_server => worker_server)
    )

    client.start_all
    worker_server.expects(:stop_all)
    client.stop_all
  end
end
