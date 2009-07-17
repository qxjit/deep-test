module DeepTest
  module Distributed
    class Beachhead < LocalDeployment
      include Demon, DRb::DRbUndumped

      MERCY_KILLING_GRACE_PERIOD = 10 * 60 unless defined?(MERCY_KILLING_GRACE_PERIOD)

      def initialize(base_path, options, connection_info)
        super options
        @connection_info = connection_info
        @base_path = base_path
      end

      def launch_mercy_killer(grace_period)
        Thread.new do
          sleep grace_period
          exit(0) unless agents_deployed?
        end
      end

      def load_files(files)
        Dir.chdir @base_path
        resolver = FilenameResolver.new(@base_path)
        files.each do |file|
          load resolver.resolve(file)
        end
        nil
      end

      def central_command
        CentralCommand.remote_reference @connection_info.address, @options.server_port
      end

      def deploy_agents
        @agents_deployed = true
        super
        warlock.exit_when_none_running
        nil
      end

      def agents_deployed?
        @agents_deployed
      end

      def forked(*args)
        $stdout.reopen("/dev/null")
        $stderr.reopen("/dev/null")
        super
      end

      def execute(address, innie, outie, grace_period)
        innie.close

        DRb.start_service "drubyall://#{address}:0", self

        DeepTest.logger.info { "Beachhead started at #{DRb.uri}" }

        outie.write DRb.uri
        outie.close

        launch_mercy_killer grace_period
        wait_for_heartbeat_to_stop
      end

      def daemonize(address, grace_period = MERCY_KILLING_GRACE_PERIOD)
        innie, outie = IO.pipe

        warlock.start "Beachhead", self, 
                      address, innie, outie, grace_period

        outie.close
        uri = innie.gets
        innie.close
        DRbObject.new_with_uri uri
      end

      def wait_for_heartbeat_to_stop
        loop do
          break if @heartbeat_stopped
          sleep 1
        end
      end

      def heartbeat_stopped
        @heartbeat_stopped = true
      end
    end
  end
end
