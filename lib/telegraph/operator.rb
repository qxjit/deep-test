require 'thread'

module Telegraph
  class Operator
    include Logging

    def self.listen(host, port, switchboard)
      new TCPServer.new(host, port), switchboard
    end

    def initialize(socket, switchboard)
      @socket = socket
      @switchboard = switchboard
      @accept_thread = Thread.new do
        loop do
          client = @socket.accept
          debug { "Accepted connection: #{client.inspect}" }
          @switchboard.add_wire Wire.new(client)
        end
      end
    end

    def port
      @socket.addr[1]
    end

    def shutdown
      debug { "Shutting down" }
      @socket.close
      @switchboard.close_all_wires
    end
  end
end
