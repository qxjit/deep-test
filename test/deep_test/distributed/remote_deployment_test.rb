require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "load_files broadcasts before_sync" do
        class FakeListener; end
        deployment = RemoteDeployment.new(
          options = Options.new(:worker_listener => FakeListener,
                                :sync_options => {:source => "/tmp"}),
          landing_ship = stub_everything(:spawn_worker_server => stub_everything),
          failover_deployment = mock
        )
        FakeListener.any_instance.expects(:before_sync)
        deployment.expects(:load)
        deployment.load_files ["filelist"]

      end

      test "load_files pushes code to remote machines" do
        deployment = RemoteDeployment.new(
          options = Options.new(:sync_options => {:source => "/tmp"}),
          landing_ship = stub_everything(:spawn_worker_server => stub_everything),
          failover_deployment = mock
        )

        landing_ship.expects(:push_code).with(options)
        deployment.expects(:load)
        deployment.load_files ["filelist"]
      end

      test "load_files loads files on worker server" do
        worker_server = stub_everything
        deployment = RemoteDeployment.new(
          Options.new(:sync_options => {:source => "/tmp"}),
          landing_ship = stub_everything(:spawn_worker_server => worker_server),
          failover_deployment = mock
        )

        worker_server.expects(:load_files).with(["filelist"])
        deployment.expects(:load)
        deployment.load_files ["filelist"]
      end

      test "load_files loads files locally" do
        worker_server = stub_everything
        deployment = RemoteDeployment.new(
          Options.new(:sync_options => {:source => "/tmp"}),
          landing_ship = stub_everything(:spawn_worker_server => worker_server),
          failover_deployment = mock
        )

        deployment.expects(:load).with("filelist")
        deployment.load_files ["filelist"]
      end

      test "start_all starts workers on worker server" do
        deployment = RemoteDeployment.new(
          options = Options.new(:sync_options => {:source => "/tmp"}),
          landing_ship = stub_everything,
          failover_deployment = mock
        )

        landing_ship.expects(:spawn_worker_server).with(options).
          returns(worker_server = stub_everything)

        deployment.expects(:load)
        deployment.load_files ["filelist"]

        worker_server.expects(:start_all)
        deployment.start_all
      end

      test "stop_all stops workers on worker server that was spawned in load_files" do
        worker_server = stub_everything
        deployment = RemoteDeployment.new(
          Options.new(:sync_options => {:source => "/tmp"}),
          landing_ship = stub_everything(:spawn_worker_server => worker_server),
          failover_deployment = mock
        )

        deployment.expects(:load)
        deployment.load_files ["filelist"]

        worker_server.expects(:stop_all)
        deployment.stop_all
      end

      test "exception in start_all causes failover to failover_deployment" do
        deployment = RemoteDeployment.new(
          options = Options.new(:sync_options => {:source => "/tmp"}, :ui => UI::Null),
          landing_ship = stub_everything,
          failover_deployment = mock
        )

        landing_ship.expects(:spawn_worker_server).with(options).
          returns(worker_server = mock)

        worker_server.expects(:load_files)
        deployment.expects(:load)
        deployment.load_files ["filelist"]

        worker_server.expects(:start_all).raises("An Error")

        failover_deployment.expects(:start_all)
        deployment.start_all

        failover_deployment.expects(:stop_all)
        deployment.stop_all
      end

      test "exception in push_code causes failover to failover_deployment" do
        deployment = RemoteDeployment.new(
          options = Options.new(:sync_options => {:source => "/tmp"}, :ui => UI::Null),
          landing_ship = mock,
          failover_deployment = mock
        )

        landing_ship.expects(:push_code).raises("An Error")

        deployment.expects(:load)
        deployment.load_files ["filelist"]

        failover_deployment.expects(:start_all)
        deployment.start_all

        failover_deployment.expects(:stop_all)
        deployment.stop_all
      end

      test "exception in load_files causes failover to failover_deployment" do
        deployment = RemoteDeployment.new(
          options = Options.new(:sync_options => {:source => "/tmp"}, :ui => UI::Null),
          landing_ship = stub_everything,
          failover_deployment = mock
        )

        landing_ship.expects(:spawn_worker_server).with(options).
          returns(worker_server = Object.new)

        worker_server.instance_eval do
          def calls() @calls ||= []; end
          def method_missing(sym, *args) calls << sym; end
          def load_files(filelist) raise "An Error"; end
        end

        deployment.expects(:load)
        deployment.load_files ["filelist"]

        failover_deployment.expects(:start_all)
        deployment.start_all

        failover_deployment.expects(:stop_all)
        deployment.stop_all

        assert_equal [], worker_server.calls
      end

      test "exception from start_all of failover_deployment is raised" do
        deployment = RemoteDeployment.new(
          options = Options.new(:sync_options => {:source => "/tmp"}, :ui => UI::Null),
          landing_ship = stub_everything,
          failover_deployment = mock
        )

        landing_ship.expects(:spawn_worker_server).with(options).
          returns(worker_server = mock)

        worker_server.expects(:load_files).raises("An Error")
        deployment.expects(:load)
        deployment.load_files ["filelist"]

        failover_deployment.expects(:start_all).raises("Failover Error").then.returns(nil)

        begin 
          deployment.start_all
          flunk
        rescue RuntimeError => e
          assert_equal "Failover Error", e.message
        end
      end
    end
  end
end
