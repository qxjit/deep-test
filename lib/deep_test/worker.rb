module DeepTest
  class Worker
    attr_reader :number

    def initialize(number, central_command, listener)
      @number = number
      @central_command = central_command
      @listener = listener
    end

    def run
      @listener.starting(self)
      while work_unit = next_work_unit
        @listener.starting_work(self, work_unit)

        result = begin
                   work_unit.run
                 rescue Exception => error
                   Error.new(work_unit, error)
                 end

        @listener.finished_work(self, work_unit, result)
        @central_command.write_result result
        if ENV['DEEP_TEST_SHOW_WORKER_DOTS'] == 'yes'
          $stdout.print '.'
          $stdout.flush
        end
      end
    rescue CentralCommand::NoWorkUnitsRemainingError
      DeepTest.logger.debug { "Worker #{number}: no more work to do" }
    end

    def next_work_unit
      @central_command.take_work
    rescue CentralCommand::NoWorkUnitsAvailableError
      sleep 0.02
      retry
    end

    class Error
      attr_accessor :work_unit, :error

      def initialize(work_unit, error)
        @work_unit, @error = work_unit, error
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
