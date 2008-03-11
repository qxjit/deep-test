module DeepTest
  class TupleSpaceFactory
    def self.tuple_space(options)
      require "rinda/ring"
      require "socket"
      DRb.start_service
      ts = Rinda::RingFinger.new([Socket.gethostname],options.server_port).lookup_ring_any
      DeepTest.logger.debug "Connected to DeepTest server at #{ts.__drburi}"
      Rinda::TupleSpaceProxy.new ts      
    end
  end
end
