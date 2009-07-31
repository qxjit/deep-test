module Telegraph
  class Wire
    include Logging

    attr_reader :stream

    def self.connect(host, port)
      wire = new TCPSocket.new(host, port)
      return wire unless block_given?
      begin
        yield wire
      ensure
        wire.close
      end
    end

    def initialize(stream)
      @sequence = AckSequence.new
      @stream = stream
    end

    def close
      if @stream.closed?
        debug { "stream already closed" }
      else
        debug { "closing stream #{@stream.inspect}" }
        @stream.close
      end
    end

    def closed?
      @stream.closed?
    end

    def send_message(body, options = {})
      sequence_ack = options[:ack] ? options[:ack].sequence_number : nil
      message = Message.new(body, @sequence.next, sequence_ack)
      message.write stream
      unacked_sequences_numbers[message.sequence_number] = message if options[:need_ack]
    rescue IOError, Errno::EPIPE, Errno::ECONNRESET => e
      close rescue nil
      raise LineDead, e.message
    end

    def process_messages(options = {:timeout => 0})
      yield next_message(options) while true
    rescue NoMessageAvailable
      retry
    end

    def next_message(options = {:timeout => 0})
      begin
        raise NoMessageAvailable unless IO.select [@stream], nil, nil, options[:timeout]
        message = Message.read(@stream)
        unacked_sequences_numbers.delete message.sequence_ack if message.sequence_ack
        return message
      rescue IOError, Errno::ECONNRESET => e
        raise LineDead, e.message
      end
    rescue LineDead
      close rescue nil
      raise
    end

    def unacked_sequences_numbers
      @unacked_sequences_numbers ||= {}
    end

    def unacked_messages
      unacked_sequences_numbers.values
    end
  end
end
