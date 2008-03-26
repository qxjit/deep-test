require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "number_of_workers is determined by mirror server options" do
    workers = DeepTest::Distributed::TestServerWorkers.new(
      DeepTest::Options.new({}),
      {:number_of_workers => 4}
    )

    assert_equal 4, workers.number_of_workers
  end
end
