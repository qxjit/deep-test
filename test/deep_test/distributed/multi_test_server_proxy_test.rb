require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "push_code is invoked on all ships" do
        ship_1, ship_2 = mock, mock
        options = Options.new({:ui => "UI::Null"})

        fleet = LandingFleet.new(options, [ship_1, ship_2])

        ship_1.expects(:push_code).with(options)
        ship_2.expects(:push_code).with(options)

        fleet.push_code(options)
      end

      test "establish_beachhead is invoked on all ship" do
        ship_1, ship_2 = mock, mock
        options = Options.new({:ui => "UI::Null"})

        fleet = LandingFleet.new(options, [ship_1, ship_2])

        ship_1.expects(:establish_beachhead).with(options)
        ship_2.expects(:establish_beachhead).with(options)

        fleet.establish_beachhead(options)
      end

      test "establish_beachhead returns Beachheads with each agent" do
        ship_1 = mock(:establish_beachhead => :beachhead_1)
        ship_2 = mock(:establish_beachhead => :beachhead_2)
        options = Options.new({:ui => "UI::Null"})

        fleet = LandingFleet.new(options, [ship_1, ship_2])

        LandingFleet::Beachheads.
          expects(:new).with(options, [:beachhead_1, :beachhead_2])

        fleet.establish_beachhead(options)
      end

      test "Beachheads dispatches start_all" do
        beachhead_1, beachhead_2 = mock, mock

        beachheads = LandingFleet::Beachheads.new(
          Options.new({:ui => "UI::Null"}),
          [beachhead_1, beachhead_2]
        )

        beachhead_1.expects(:start_all)
        beachhead_2.expects(:start_all)

        beachheads.start_all
      end

      test "Beachheads dispatches stop_all" do
        beachhead_1, beachhead_2 = mock, mock

        beachheads = LandingFleet::Beachheads.new(
          Options.new({:ui => "UI::Null"}),
          [beachhead_1, beachhead_2]
        )

        beachhead_1.expects(:stop_all)
        beachhead_2.expects(:stop_all)

        beachheads.stop_all
      end

      test "Beachheads stop_all ignores connection errors" do
        beachhead_1 = mock

        beachheads = LandingFleet::Beachheads.new(
          Options.new({:ui => "UI::Null"}),
          [beachhead_1]
        )

        beachhead_1.expects(:__drburi).never
        beachhead_1.expects(:stop_all).raises(DRb::DRbConnError)

        beachheads.stop_all
      end

      test "Beachheads dispatches load_files" do
        beachhead_1, beachhead_2 = mock, mock

        beachheads = LandingFleet::Beachheads.new(
          Options.new({:ui => "UI::Null"}),
          [beachhead_1, beachhead_2]
        )

        beachhead_1.expects(:load_files).with(:filelist)
        beachhead_2.expects(:load_files).with(:filelist)

        beachheads.load_files :filelist
      end
    end
  end
end
