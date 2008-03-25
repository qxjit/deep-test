module DeepTest
  module Distributed
    class MirrorServerWorkers < LocalWorkers
      def initialize(options, mirror_server_config)
        super(options)
        @mirror_server_config = mirror_server_config
      end
      
      def number_of_workers
        @mirror_server_config[:number_of_workers]
      end

      def start_all
        super
        @warlock.exit_when_none_running
      end
    end
  end
end
