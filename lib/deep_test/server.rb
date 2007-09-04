module DeepTest
  class Server
    def self.start
      require 'rinda/ring'
      require 'rinda/tuplespace'
      require 'test/unit'
      require 'test/unit/testresult'
      require 'deep_test'
      DRb.start_service
      ts = Rinda::TupleSpace.new
      Rinda::RingServer.new(ts)
      Rinda::RingProvider.new(:TupleSpace, ts, 'Tuple Space').provide
      DRb.thread.join
    end
  end
end
