module DeepTest
  class Server
    PORT = 6969
    
    def self.start
      require 'rinda/ring'
      require 'rinda/tuplespace'
      require 'test/unit'
      require 'test/unit/testresult'
      begin
        require 'rubygems'
        require 'spec' 
      rescue 
      end 
      require 'deep_test'
      DRb.start_service
      ts = Rinda::TupleSpace.new
      Rinda::RingServer.new(ts, PORT)
      puts "Started DeepTest service at #{DRb.uri}"
      DRb.thread.join
    end
  end
end

if __FILE__ == $0
  DeepTest::Server.start
end
