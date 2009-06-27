module DeepTest
  module Distributed
    class ThroughputWorkerClient
      def initialize(options, landing_ship)
        @options = options
        @landing_ship = landing_ship
      end

      def deploy_agents
        @beachhead = @landing_ship.establish_beachhead(@options)
        @beachhead.deploy_agents
      end

      def terminate_agents
        @beachhead.terminate_agents
      end
    end
  end
end
