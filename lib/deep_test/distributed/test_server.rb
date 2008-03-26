module DeepTest
  module Distributed
    class TestServer
      DEFAULT_CONFIG = {
        :mirror_base_path => "/tmp",
        :uri => "druby://#{Socket.gethostname}:4022",
        :number_of_workers => 2
      } unless defined?(DEFAULT_CONFIG)

      def initialize(config)
        @config = config
      end

      def spawn_worker_server(options)
        DeepTest.logger.debug("mirror spawn_worker_server for #{options.origin_hostname}")
        RemoteWorkerServer.start(options.sync_options[:source],
                                 options.mirror_path(@config[:mirror_base_path]),
                                 TestServerWorkers.new(options, @config))
      end

      def status
        TestServerStatus.new(
          DRb.uri, 
          @config[:number_of_workers],
          RemoteWorkerServer.running_server_count
        )
      end

      def sync(options)
        DeepTest.logger.debug "mirror sync for #{options.origin_hostname}"
        path = options.mirror_path(@config[:mirror_base_path])
        DeepTest.logger.debug "Syncing #{options.sync_options[:source]} to #{path}"
        RSync.sync(options, path)
      end

      def servers
        [DRbObject.new_with_uri(DRb.uri)]
      end

      def self.start(config)
        server = DeepTest::Distributed::TestServer.new(config)
        DRb.start_service(config[:uri], server)
        DeepTest.logger.info "TestServer listening at #{DRb.uri}"
        DRb.thread.join
      end

      def self.parse_args(args)
        options = DeepTest::Distributed::TestServer::DEFAULT_CONFIG.dup
        OptionParser.new do |opts|
          opts.banner = "Usage: deep_test test_server [options]"

          opts.on("--mirror_base_path PATH", "Absolute path to keep mirror working copies at") do |v|
            options[:mirror_base_path] = v
          end

          opts.on("--uri URI", "DRb URI to bind server to") do |v|
            options[:uri] = v
          end

          opts.on("--number_of_workers NUM", "Number of workers to start when running tests") do |v|
            options[:number_of_workers] = v.to_i
          end

          opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
          end
        end.parse(args)
        options
      end

      def self.connect(options)
        servers = DRbObject.new_with_uri(options.distributed_server).servers
        MultiTestServerProxy.new(options, servers)
      end
    end
  end
end
