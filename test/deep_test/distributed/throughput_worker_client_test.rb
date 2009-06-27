require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "start_all starts agents on a new agent server" do
        client = ThroughputWorkerClient.new(
          options = Options.new({}),
          landing_ship = stub_everything
        )

        landing_ship.expects(:establish_beachhead).with(options).
          returns(beachhead = stub_everything)

        beachhead.expects(:start_all)
        client.start_all
      end

      test "stop_all stops agents on agent server that was spawned in start_all" do
        beachhead = stub_everything
        client = ThroughputWorkerClient.new(
          Options.new({}),
          landing_ship = stub_everything(:establish_beachhead => beachhead)
        )

        client.start_all
        beachhead.expects(:stop_all)
        client.stop_all
      end
    end
  end
end
