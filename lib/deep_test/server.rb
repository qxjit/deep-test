module DeepTest
  class Server
    def self.start(options)
      DRb.start_service
      Rinda::RingServer.new(Rinda::TupleSpace.new, options.server_port)
      DeepTest.logger.info "Started DeepTest service at #{DRb.uri}"
      yield if block_given?
      DRb.thread.join
    end
  end
end
