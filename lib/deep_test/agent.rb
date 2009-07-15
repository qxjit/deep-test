module DeepTest
  class Agent
    include Demon
    attr_reader :number

    def initialize(number, options, central_command, listener)
      @number = number
      @central_command = central_command
      @listener = listener
      @wire = Telegraph::Wire.connect(options.origin_hostname, options.telegraph_port)
    end

    def execute
      reseed_random_numbers
      reconnect_to_database

      @listener.starting(self)
      while work_unit = next_work_unit
        @listener.starting_work(self, work_unit)

        result = begin
                   work_unit.run
                 rescue Exception => error
                   Error.new(work_unit, error)
                 end

        @listener.finished_work(self, work_unit, result)
        Timeout.timeout(2) { @central_command.write_result result }
        if ENV['DEEP_TEST_SHOW_WORKER_DOTS'] == 'yes'
          $stdout.print '.'
          $stdout.flush
        end
      end
    rescue CentralCommand::NoWorkUnitsRemainingError
      DeepTest.logger.debug { "Agent #{number}: no more work to do" }
    rescue DRb::DRbConnError, Timeout::Error
      DeepTest.logger.debug { "Unable to contact DRb server.  Exiting" }
    end

    def heartbeat_stopped
      @heartbeat_stopped = true
    end

    private

    def next_work_unit
      @wire.send_message CentralCommand::NeedWork
      begin
        return nil if @heartbeat_stopped
        message = @wire.next_message(:timeout => 2)
        return message == CentralCommand::NoMoreWork ? nil : message
      rescue Telegraph::NoMessageAvailable
        retry
      rescue Telegraph::LineDead
        return nil
      end
    end

    def reconnect_to_database
      ActiveRecord::Base.connection.reconnect! if defined?(ActiveRecord::Base)
    end

    def reseed_random_numbers
      srand
    end


    class Error
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
