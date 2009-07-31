require 'thread'

module Telegraph
  class Operator
    include Logging

    attr_reader :switchboard

    def self.listen(host, port, switchboard = Switchboard.new)
      new TCPServer.new(host, port), switchboard
    end

    def initialize(socket, switchboard)
      @socket = socket
      @switchboard = switchboard
      @accept_thread = Thread.new do
        @socket.listen 100
        loop do
          if @should_shutdown
            @socket.close
            @switchboard.close_all_wires
            break
          end

          begin
            client = @socket.accept_nonblock
            debug { "Accepted connection: #{client.inspect}" }
            @switchboard.add_wire Wire.new(client)
          rescue Errno::EAGAIN, Errno::ECONNABORTED, Errno::EPROTO, Errno::EINTR
            connection_ready, = IO.select([@socket], nil, nil, 0.25)
            retry if connection_ready
          end
        end
      end
    end

    def port
      @socket.addr[1]
    end

    def shutdown
      debug { "Shutting down" }
      @should_shutdown = true
      @accept_thread.join
    end
  end
end
