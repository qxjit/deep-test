module DeepTest
  module Distributed
    class MultiTestServerProxy
      def initialize(options, slaves)
        DeepTest.logger.debug { "MultiTestServerProxy#initialize #{slaves.length} slaves" }
        @slave_controller = DispatchController.new(options, slaves)
      end

      def spawn_worker_server(options)
        DeepTest.logger.debug { "dispatch spawn_worker_server for #{options.origin_hostname}" }
        WorkerServerProxy.new options,
                              @slave_controller.dispatch(:spawn_worker_server, 
                                                         options)
      end

      def push_code(options)
        DeepTest.logger.debug { "dispatch push_code for #{options.origin_hostname}" }
        @slave_controller.dispatch(:push_code, options)
      end

      class WorkerServerProxy
        def initialize(options, slaves)
          DeepTest.logger.debug { "WorkerServerProxy#initialize #{slaves.inspect}" }
          @slave_controller = DispatchController.new(options, slaves)
        end

        def load_files(files)
          DeepTest.logger.debug { "dispatch load_files" }
          @slave_controller.dispatch(:load_files, files)
        end

        def start_all
          DeepTest.logger.debug { "dispatch start_all" }
          @slave_controller.dispatch(:start_all)
        end

        def stop_all
          DeepTest.logger.debug { "dispatch stop_all" }
          @slave_controller.dispatch_with_options(:stop_all, :ignore_connection_error => true)
        end
      end
    end
  end
end
