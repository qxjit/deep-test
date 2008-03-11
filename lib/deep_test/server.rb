module DeepTest
  class Server
    PORT = 6969 unless defined?(PORT)
    
    def self.start
      DRb.start_service
      Rinda::RingServer.new(Rinda::TupleSpace.new, PORT)
      DeepTest.logger.info "Started DeepTest service at #{DRb.uri}"
      yield if block_given?
      DRb.thread.join
    end
  end
end
