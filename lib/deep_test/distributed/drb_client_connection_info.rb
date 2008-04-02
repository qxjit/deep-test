module DeepTest
  module Distributed
    class DRbClientConnectionInfo
      attr_reader :address

      def initialize
        info = Thread.current['DRb']
        raise "No DRb client found" unless info && info['client']
        @address = info['client'].peeraddr[2]
      end
    end
  end
end
