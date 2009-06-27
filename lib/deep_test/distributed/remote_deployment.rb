module DeepTest
  module Distributed
    class RemoteDeployment
      def initialize(options, landing_ship, failover_deployment)
        @failover_deployment = failover_deployment
        @options = options
        @landing_ship = landing_ship
      end

      def load_files(filelist)
        # load one file before calling listeners to make sure environment has
        # been initialized as expected
        #
        load filelist.first
        @options.new_listener_list.before_sync

        t = Thread.new do
          @landing_ship.push_code(@options)
          @worker_server = @landing_ship.spawn_worker_server(@options)
          @worker_server.load_files filelist
        end

        filelist[1..-1].each {|f| load f}

        begin
          t.join
        rescue => e
          # The failover here doesn't invoke load_files on the failover_deployment
          # because it will be a LocalDeployment, which forks from the current 
          # process.  The fact that we depend in this here is damp...
          #
          fail_over("load_files", e)
        end
      end

      def start_all
        @worker_server.start_all
      rescue => e
        raise if failed_over?
        fail_over("start_all", e)
        retry
      end

      def stop_all
        @worker_server.stop_all
      end

      def fail_over(method, exception)
        @options.ui_instance.distributed_failover_to_local(method, exception)
        @worker_server = @failover_deployment
      end

      def failed_over?
        @worker_server == @failover_deployment
      end
    end
  end
end
