module Telegraph
  class Wire
    include Logging

    attr_reader :stream

    def self.connect(host, port)
      new TCPSocket.new(host, port)
    end

    def initialize(stream)
      @stream = stream
    end

    def close
      debug { "closing stream" }
      @stream.close
    end

    def closed?
      @stream.closed?
    end

    def send_message(message)
      message_string = Marshal.dump(message)
      debug { "sending message of size #{message_string.length}"}
      @stream.write [message_string.length].pack("N") + message_string
    rescue IOError, Errno::EPIPE, Errno::ECONNRESET => e
      close rescue nil
      raise LineDead, e.message
    end

    def next_message(options = {:timeout => 0})
      begin
        raise NoMessageAvailable unless IO.select [@stream], nil, nil, options[:timeout]
        size = @stream.read(4)
        raise LineDead, "connection closed" unless size
        message_string = @stream.read(size.unpack("N")[0])
        debug { "read message of size #{message_string.length}" }
        raise LineDead, "connection closed" unless message_string
        return Marshal.load(message_string)
      rescue IOError, Errno::ECONNRESET => e
        raise LineDead, e.message
      end
    rescue LineDead
      close rescue nil
      raise
    end
  end
end
