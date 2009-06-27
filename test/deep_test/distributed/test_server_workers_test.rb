require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "number_of_workers is determined by mirror server options" do
        workers = TestServerWorkers.new(
          Options.new({}), {:number_of_workers => 4}, mock
        )

        assert_equal 4, workers.number_of_workers
      end

      test "central_command is retrieved using client connection information" do
        workers = TestServerWorkers.new(
          options = Options.new({}),
          {:number_of_workers => 4},
          mock(:address => "address")
        )
        DeepTest::CentralCommand.expects(:remote_reference).
          with("address", options.server_port).returns(:central_command_reference)

        assert_equal :central_command_reference, workers.central_command
      end
    end
  end
end
