module DeepTest
  module Distributed
    class Beachhead
      include DRb::DRbUndumped

      MERCY_KILLING_GRACE_PERIOD = 10 * 60 unless defined?(MERCY_KILLING_GRACE_PERIOD)

      def initialize(base_path, deployment)
        @base_path = base_path
        @deployment = deployment
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
      end

      def start_all
        @agents_deployed = true
        @deployment.start_all
      end

      def stop_all
        Thread.new do
          @deployment.stop_all
        end
      end

      def agents_deployed?
        @agents_deployed
      end

      def self.warlock
        @warlock ||= DeepTest::Warlock.new
      end

      def self.running_server_count
        @warlock.demon_count if @warlock
      end

      def self.stop_all
        @warlock.stop_all if @warlock
      end

      def self.start(address, base_path, deployment, grace_period = MERCY_KILLING_GRACE_PERIOD)
        innie, outie = IO.pipe

        warlock.start("Beachhead") do
          innie.close

          server = new(base_path, deployment)

          DRb.start_service("drubyall://#{address}:0", server)
          DeepTest.logger.info { "Beachhead started at #{DRb.uri}" }

          outie.write DRb.uri
          outie.close

          server.launch_mercy_killer(grace_period)

          yield if block_given?

          DRb.thread.join
        end

        outie.close
        uri = innie.gets
        innie.close
        DRbObject.new_with_uri(uri)
      end

    end
  end
end
