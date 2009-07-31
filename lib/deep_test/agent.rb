module DeepTest
  class Agent
    include Demon
    attr_reader :number

    def initialize(number, options, listener)
      @number = number
      @listener = listener
      @options = options
    end

    def connect
      @wire = Telegraph::Wire.connect(@options.origin_hostname, @options.server_port)
    end

    def execute
      connect

      reseed_random_numbers
      reconnect_to_database

      @listener.starting(self)
      @wire.send_message CentralCommand::NeedWork

      while work_unit_message = next_work_unit_message
        @listener.starting_work(self, work_unit_message.body)

        result = begin
                   work_unit_message.body.run
                 rescue Exception => error
                   Error.new(work_unit_message.body, error)
                 end

        @listener.finished_work(self, work_unit_message.body, result)
        send_result work_unit_message, result
      end
    rescue CentralCommand::NoWorkUnitsRemainingError
      DeepTest.logger.debug { "Agent #{number}: no more work to do" }
    end

    def next_work_unit_message
      begin
        message = @wire.next_message(:timeout => 2)
        return message.body == CentralCommand::NoMoreWork ? nil : message
      rescue Telegraph::NoMessageAvailable
        DeepTest.logger.debug { "Agent: NoMessageAvailable" }
        retry
      rescue Telegraph::LineDead
        DeepTest.logger.debug { "Agent: LineDead" }
        return nil
      end
    end

    def send_result(work_unit_message, result)
      @wire.send_message result, :ack => work_unit_message
    end

    def reconnect_to_database
      ActiveRecord::Base.connection.reconnect! if defined?(ActiveRecord::Base)
    end

    def reseed_random_numbers
      srand
    end


    class Error
      include CentralCommand::Result

      attr_accessor :work_unit, :error

      def initialize(work_unit, error)
        @work_unit, @error = work_unit, error
      end

      def _dump(limit)
        Marshal.dump([@work_unit, @error], limit)
      rescue
        Marshal.dump(["<< Undumpable >>", @error], limit)
      end

      def self._load(string)
        new *Marshal.load(string)
      end

      def ==(other)
        work_unit == other.work_unit &&
            error == other.error
      end

      def to_s
        "#{@work_unit}: #{@error}\n" + (@error.backtrace || []).join("\n")
      end
    end
  end
end
