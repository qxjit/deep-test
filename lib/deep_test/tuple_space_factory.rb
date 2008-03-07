module DeepTest
  class TupleSpaceFactory
    def self.tuple_space
      require "rinda/ring"
      require "socket"
      DRb.start_service
      ts = Rinda::RingFinger.new([Socket.gethostname],DeepTest::Server::PORT).lookup_ring_any
      DeepTest.logger.debug "Connected to DeepTest server at #{ts.__drburi}"
      Rinda::TupleSpaceProxy.new ts      
    end
  end
end
