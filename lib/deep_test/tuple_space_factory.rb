module DeepTest
  class TupleSpaceFactory
    def self.tuple_space
      require "rinda/ring"
      DRb.start_service
      ts = Rinda::RingFinger.new(['localhost'],DeepTest::Server::PORT).lookup_ring_any
      puts "Connected to DeepTest server at #{ts.__drburi}"
      Rinda::TupleSpaceProxy.new ts      
    end
  end
end
