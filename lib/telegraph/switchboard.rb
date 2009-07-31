module Telegraph
  class Switchboard
    include Logging

    def process_messages(options = {:timeout => 0})
      yield next_message(options) while true
    rescue NoMessageAvailable
      retry
    end

    def next_message(options = {:timeout => 0})
      debug { "Waiting for next message on any of #{live_wires.size} wires for #{options[:timeout]} seconds" }

      if live_wires.empty?
        sleep 0.01
        Thread.pass 
        raise NoMessageAvailable 
      end

      readers, = IO.select live_wires.map {|w| w.stream}, nil, nil, options[:timeout]
      raise NoMessageAvailable unless readers

      wire = using_wires {|wires| wires.detect {|w| w.stream == readers.first} }
      return wire.next_message(options.merge(:timeout => 0)), wire
    rescue LineDead => e
      debug { "LineDead: #{e.message} while reading message from wire" }
      raise NoMessageAvailable
    end

    def any_live_wires?
      live_wires.any?
    end

    def drop_wire(wire)
      using_wires {|w| w.delete wire }
    end

    def add_wire(wire)
      using_wires {|w| w << wire }
    end

    def close_all_wires
      debug { "Closing all wires" }
      using_wires {|w| w.each { |wire| wire.close rescue nil } }
    end

    def live_wires
      using_wires {|w| w.select {|wire| !wire.closed?}}
    end

    def using_wires
      @wires ||= []
      @wires_mutex ||= Mutex.new
      @wires_mutex.synchronize { yield @wires }
    end
  end
end
