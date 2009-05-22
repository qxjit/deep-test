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

      def self.new_dispatch_controller(options)
        servers = options.adhoc_distributed_hosts.split(' ').map do |host|
          AdHocServer.new :address => host, :work_dir => '/tmp'
        end
        MultiTestServerProxy.new(options, servers)
      end
    end
  end
end
