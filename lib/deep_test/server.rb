module DeepTest
  class Server
    PORT = 6969
    
    def self.start
      require 'rinda/ring'
      require 'rinda/tuplespace'
      require 'test/unit'
      require 'test/unit/testresult'
      require 'deep_test'
      DRb.start_service
      Rinda::RingServer.new(Rinda::TupleSpace.new, PORT)
      DeepTest.logger.info "Started DeepTest service at #{DRb.uri}"
      DRb.thread.join
    end
  end
end
