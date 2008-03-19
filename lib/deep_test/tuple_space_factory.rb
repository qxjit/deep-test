module DeepTest
  class TupleSpaceFactory
    class << self
      def tuple_space(options)
        start_drb
        tuple_space = find_tuple_space(options.server_port)
        return Rinda::TupleSpaceProxy.new(tuple_space)
      end
      
      def hostnames
        [Socket.gethostname, "localhost"]
      end
      
    private
    
      def find_tuple_space(server_port)
        tuple_space = Rinda::RingFinger.new(hostnames, server_port).lookup_ring_any
        add_debug_to_logger("Connected to DeepTest server at #{tuple_space.__drburi}")
        
        return tuple_space
      end
    
      def start_drb
        DRb.start_service
      end
    
      def add_debug_to_logger(message)
        DeepTest.logger.debug(message)
      end
    end
  end
end
