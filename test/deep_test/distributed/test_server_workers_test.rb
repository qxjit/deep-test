require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "number_of_workers is determined by mirror server options" do
    workers = DeepTest::Distributed::TestServerWorkers.new(
      DeepTest::Options.new({}),
      {:number_of_workers => 4},
      mock
    )

    assert_equal 4, workers.number_of_workers
  end

  test "server is retrieved using client connection information" do
    workers = DeepTest::Distributed::TestServerWorkers.new(
      options = DeepTest::Options.new({}),
      {:number_of_workers => 4},
      mock(:address => "address")
    )
    DeepTest::Server.expects(:remote_reference).
      with("address", options.server_port).
      returns(:server_reference)

    assert_equal :server_reference, workers.server
  end
end
