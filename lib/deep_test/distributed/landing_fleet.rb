module DeepTest
  module Distributed
    class LandingFleet
      def initialize(options, slaves)
        DeepTest.logger.debug { "LandingFleet#initialize #{slaves.length} slaves" }
        @slave_controller = DispatchController.new(options, slaves)
      end

      def establish_beachhead(options)
        DeepTest.logger.debug { "dispatch establish_beachhead for #{options.origin_hostname}" }
        Beachheads.new options,
                              @slave_controller.dispatch(:establish_beachhead, 
                                                         options)
      end

      def push_code(options)
        DeepTest.logger.debug { "dispatch push_code for #{options.origin_hostname}" }
        @slave_controller.dispatch(:push_code, options)
      end

      class Beachheads
        def initialize(options, slaves)
          DeepTest.logger.debug { "Beachheads#initialize #{slaves.inspect}" }
          @slave_controller = DispatchController.new(options, slaves)
        end

        def load_files(files)
          DeepTest.logger.debug { "dispatch load_files" }
          @slave_controller.dispatch(:load_files, files)
        end

        def deploy_agents
          DeepTest.logger.debug { "dispatch deploy_agents" }
          @slave_controller.dispatch(:deploy_agents)
        end

        def terminate_agents
          DeepTest.logger.debug { "dispatch terminate_agents" }
          @slave_controller.dispatch_with_options(:terminate_agents, :ignore_connection_error => true)
        end
      end
    end
  end
end
