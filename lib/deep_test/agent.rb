module DeepTest
  class Agent
    include Demon
    attr_reader :number

    def initialize(number, options, listener)
      @number = number
      @listener = listener
      @options = options
    end

    def connect(stream_to_parent_process)
      DeepTest.logger.debug { "Agent: Connecting to #{@options.origin_hostname}:#{@options.server_port}" }
      @options.connect_to_central_command do |wire|
        stream_to_parent_process.puts "Connected"
        stream_to_parent_process.close rescue nil
        yield wire
      end
    ensure
      stream_to_parent_process.close unless stream_to_parent_process.closed?
    end

    def execute(stream_from_child_process, stream_to_parent_process)
      stream_from_child_process.close
      connect(stream_to_parent_process) do |wire|
        reseed_random_numbers
        reconnect_to_database

        @listener.starting(self)
        wire.send_message CentralCommand::NeedWork

        while work_unit_message = next_work_unit_message(wire)
          @listener.starting_work(self, work_unit_message.body)

          result = begin
                     Metrics::Measurement.send_home("Agents Performing Work", wire, @options) do
                       work_unit_message.body.run
                     end
                   rescue Exception => error
                     Error.new(work_unit_message.body, error)
                   end

          @listener.finished_work(self, work_unit_message.body, result)
          send_result wire, work_unit_message, result
        end
      end
    rescue CentralCommand::NoWorkUnitsRemainingError
      DeepTest.logger.debug { "Agent #{number}: no more work to do" }
    end

    def next_work_unit_message(wire)
      Metrics::Measurement.send_home("Agents Retrieving Work", wire, @options) do
        begin
          message = wire.next_message(:timeout => 2)
          next message.body == CentralCommand::NoMoreWork ? nil : message
        rescue Telegraph::NoMessageAvailable
          DeepTest.logger.debug { "Agent: NoMessageAvailable" }
          retry
        rescue Telegraph::LineDead
          DeepTest.logger.debug { "Agent: LineDead" }
          next nil
        end
      end
    end

    def send_result(wire, work_unit_message, result)
      wire.send_message result, :ack => work_unit_message
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
