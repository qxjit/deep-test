module Telegraph
  class Message
    include Logging

    attr_reader :body, :sequence_number, :sequence_ack

    def initialize(body, sequence_number, sequence_ack)
      @body = body
      @sequence_number = sequence_number
      @sequence_ack = sequence_ack
    end

    def write(stream)
      message_data = Marshal.dump(body)
      debug { "send #{message_data[4..20]}... (#{message_data.length} bytes)" }
      stream.write [message_data.size, @sequence_number, @sequence_ack || 0].pack("NNN") + message_data
    end

    class <<self
      include Logging

      def read(stream)
        header_data = read_data(stream, 12, "header")
        size, sequence_number, sequence_ack = header_data.unpack("NNN")

        message_data = read_data(stream, size, "message")
        debug { "read #{message_data[4..20]}... (#{message_data.length} bytes)" }
        Message.new Marshal.load(message_data), sequence_number, (sequence_ack == 0 ? nil : sequence_ack)
      end

      def read_data(stream, length, label)
        data = stream.read(length)
        raise IOError, "connection closed" unless data
        raise IOError, "incomplete #{label} data" unless data.length == length
        data
      end
    end
  end
end
