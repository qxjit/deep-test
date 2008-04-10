module DeepTest
  module Distributed
    class DRbClientConnectionInfo
      attr_reader :address

      def initialize
        info = Thread.current['DRb']
        raise "No DRb client found" unless info && info['client']
        peeraddr = info['client'].peeraddr
        DeepTest.logger.debug("DRbClientConnection info: #{peeraddr.inspect}")
        @address = peeraddr[3]
      end
    end
  end
end
