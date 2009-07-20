require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "push_code is invoked on all servers" do
        server_1, server_2 = mock, mock
        options = Options.new({:ui => "UI::Null"})

        fleet = LandingFleet.new(options, [server_1, server_2])

        server_1.expects(:push_code).with(options)
        server_2.expects(:push_code).with(options)

        fleet.push_code(options)
      end

      test "establish_beachhead is invoked on all server" do
        server_1, server_2 = mock, mock
        options = Options.new({:ui => "UI::Null"})

        fleet = LandingFleet.new(options, [server_1, server_2])

        server_1.expects(:establish_beachhead).with(options)
        server_2.expects(:establish_beachhead).with(options)

        fleet.establish_beachhead(options)
      end

      test "load_files is invoked on all server" do
        server_1, server_2 = mock, mock
        options = Options.new({:ui => "UI::Null"})

        fleet = LandingFleet.new(options, [server_1, server_2])

        server_1.expects(:load_files).with(['a'])
        server_2.expects(:load_files).with(['a'])

        fleet.load_files(['a'])
      end

      test "deploy_agents is invoked on all server" do
        server_1, server_2 = mock, mock
        options = Options.new({:ui => "UI::Null"})

        fleet = LandingFleet.new(options, [server_1, server_2])

        server_1.expects(:deploy_agents)
        server_2.expects(:deploy_agents)

        fleet.deploy_agents
      end
    end
  end
end
