require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "push_code is invoked on all servers" do
        server_1, server_2 = mock, mock
        options = Options.new({:ui => "UI::Null"})

        master = MultiTestServerProxy.new(options, [server_1, server_2])

        server_1.expects(:push_code).with(options)
        server_2.expects(:push_code).with(options)

        master.push_code(options)
      end

      test "establish_beachhead is invoked on all server" do
        server_1, server_2 = mock, mock
        options = Options.new({:ui => "UI::Null"})

        master = MultiTestServerProxy.new(options, [server_1, server_2])

        server_1.expects(:establish_beachhead).with(options)
        server_2.expects(:establish_beachhead).with(options)

        master.establish_beachhead(options)
      end

      test "establish_beachhead returns WorkerServerProxy with each worker" do
        server_1 = mock(:establish_beachhead => :beachhead_1)
        server_2 = mock(:establish_beachhead => :beachhead_2)
        options = Options.new({:ui => "UI::Null"})

        master = MultiTestServerProxy.new(options, [server_1, server_2])

        MultiTestServerProxy::WorkerServerProxy.
          expects(:new).with(options, [:beachhead_1, :beachhead_2])

        master.establish_beachhead(options)
      end

      test "WorkerServerProxy dispatches start_all" do
        server_1, server_2 = mock, mock

        master = MultiTestServerProxy::WorkerServerProxy.new(
          Options.new({:ui => "UI::Null"}),
          [server_1, server_2]
        )

        server_1.expects(:start_all)
        server_2.expects(:start_all)

        master.start_all
      end

      test "WorkerServerProxy dispatches stop_all" do
        server_1, server_2 = mock, mock

        master = MultiTestServerProxy::WorkerServerProxy.new(
          Options.new({:ui => "UI::Null"}),
          [server_1, server_2]
        )

        server_1.expects(:stop_all)
        server_2.expects(:stop_all)

        master.stop_all
      end

      test "WorkerServerProxy stop_all ignores connection errors" do
        server_1 = mock

        master = MultiTestServerProxy::WorkerServerProxy.new(
          Options.new({:ui => "UI::Null"}),
          [server_1]
        )

        server_1.expects(:__drburi).never
        server_1.expects(:stop_all).raises(DRb::DRbConnError)

        master.stop_all
      end

      test "WorkerServerProxy dispatches load_files" do
        server_1, server_2 = mock, mock

        master = MultiTestServerProxy::WorkerServerProxy.new(
          Options.new({:ui => "UI::Null"}),
          [server_1, server_2]
        )

        server_1.expects(:load_files).with(:filelist)
        server_2.expects(:load_files).with(:filelist)

        master.load_files :filelist
      end
    end
  end
end
