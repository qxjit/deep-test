module DeepTest
  module Distributed
    class AdHocServer
      def initialize(config)
        @config = config
      end

      def sync(options)
        DeepTest.logger.debug "mirror sync for #{options.origin_hostname}"
        path = options.mirror_path(@config[:work_dir])
        DeepTest.logger.debug "Syncing #{options.sync_options[:source]} to #{path}"
        RSync.push(@config[:address], options, path)
      end

      def spawn_worker_server(options)
        output  = `ssh -4 #{@config[:address]} '#{spawn_command(options)}'`
        output.each do |line|
          if line =~ /RemoteWorkerServer url: (.*)/
            return DRb::DRbObject.new_with_uri($1)
          end
        end
      end

      def spawn_command(options)
        "cd #{options.mirror_path(@config[:work_dir])} && " + 
        "rake start_ad_hoc_deep_test_server " + 
        "OPTIONS=#{options.to_command_line} HOST=#{@config[:address]}"
      end

      def self.new_dispatch_controller(options)
        servers = options.adhoc_distributed_hosts.split(' ').map do |host|
          AdHocServer.new :address => host, :work_dir => '/tmp'
        end
        MultiTestServerProxy.new(options, servers)
      end
    end
  end
end
