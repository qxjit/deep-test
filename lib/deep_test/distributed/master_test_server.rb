module DeepTest
  module Distributed
    class MasterTestServer
      include ERB::Util

      STATUS_PORT = 4020 unless defined?(STATUS_PORT)

      attr_reader :servers

      def initialize(servers)
        @servers = servers
      end

      def show_status(req, res)
        template = File.read(File.dirname(__FILE__) + "/show_status.rhtml")
        res.body = ERB.new(template).result(binding)
      end

      def test_server_statuses
        @servers.map do |s|
          status = begin
                     s.status
                   rescue Exception => e
                     e
                   end

          [s.__drburi, status]
        end
      end

      def self.start(uri, server_uris)
        master = start_drb(uri, server_uris)
        start_http(master)
        DeepTest.logger.info "MasterTestServer listening at #{DRb.uri}"
        DRb.thread.join
      end

      def self.start_drb(uri, server_uris)
        servers = server_uris.map {|server_uri| DRbObject.new_with_uri server_uri}
        master = DeepTest::Distributed::MasterTestServer.new(servers)
        DRb.start_service(uri, master)
        master
      end

      def self.start_http(master)
        s = WEBrick::HTTPServer.new :Port => STATUS_PORT
        s.mount_proc("/", &master.method(:show_status))
        Thread.new {s.start}
      end
    end
  end
end
