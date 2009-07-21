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
      @wire = Telegraph::Wire.connect(@options.origin_hostname, @options.telegraph_port)
    end

    def execute
      connect

      reseed_random_numbers
      reconnect_to_database

      @listener.starting(self)
      @wire.send_message CentralCommand::NeedWork

      while work_unit = next_work_unit
        @listener.starting_work(self, work_unit)

        result = begin
                   work_unit.run
                 rescue Exception => error
                   Error.new(work_unit, error)
                 end

        @listener.finished_work(self, work_unit, result)
        send_result result
      end
    rescue CentralCommand::NoWorkUnitsRemainingError
      DeepTest.logger.debug { "Agent #{number}: no more work to do" }
    end

    def next_work_unit
      begin
        message = @wire.next_message(:timeout => 2)
        return message == CentralCommand::NoMoreWork ? nil : message
      rescue Telegraph::NoMessageAvailable
        retry
      rescue Telegraph::LineDead
        return nil
      end
    end

    def send_result(result)
      @wire.send_message result
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
