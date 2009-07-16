require 'set'

module DeepTest
  class CentralCommand
    attr_reader :medic
    attr_reader :drb_server
    attr_reader :operator
    attr_reader :switchboard

    def initialize(options)
      @options = options
      @work_queue = Queue.new
      @result_queue = Queue.new
      @medic = Medic.new

      if Metrics::Gatherer.enabled?
        require File.dirname(__FILE__) + "/metrics/queue_lock_wait_time_measurement"
        @work_queue.extend Metrics::QueueLockWaitTimeMeasurement
        @result_queue.extend Metrics::QueueLockWaitTimeMeasurement
        Metrics::Gatherer.section("central_command queue lock wait times") do |s|
          s.measurement("work queue total pop wait time", @work_queue.total_pop_time)
          s.measurement("work queue total push wait time", @work_queue.total_push_time)
          s.measurement("result queue total pop wait time", @result_queue.total_pop_time)
          s.measurement("result queue total push wait time", @result_queue.total_push_time)
        end
      end
    end

    def done_with_work
      @done_with_work = true
    end

    def take_result
      raise NoAgentsRunningError if medic.triage(Agent).fatal?
      Timeout.timeout(1, CheckIfAgentsAreStillRunning) { @result_queue.pop }
    rescue CheckIfAgentsAreStillRunning
      retry
    end

    def take_work
      @work_queue.pop(true)
    rescue ThreadError => e
      if e.message == "queue empty"
        raise NoWorkUnitsRemainingError if @done_with_work
        raise NoWorkUnitsAvailableError
      else
        raise
      end
    end

    def write_result(result)
      @result_queue.push result
      nil
    end

    def write_work(work_unit)
      @work_queue.push work_unit
      nil
    end

    def stdout
      $stdout
    end

    def stderr
      $stderr
    end

    def self.start(options)
      central_command = new(options)
      central_command.start
      central_command
    end

    def start
      @drb_server = DRb::DRbServer.new("druby://0.0.0.0:#{@options.server_port || 0}", self)

      DeepTest.logger.info { "Started DeepTest service at #{drb_server.uri}" }

      @options.server_port = URI.parse(drb_server.uri).port
      @switchboard = Telegraph::Switchboard.new
      @operator = Telegraph::Operator.listen("0.0.0.0", 0, @switchboard)
      @options.telegraph_port = @operator.port

      @process_messages_thread = Thread.new { process_messages }
    end

    unless defined?(NeedWork)
      NeedWork = "NeedWork" 
      NoMoreWork = "NoMoreWork"
      module Result; end
    end

    def process_messages
      loop do
        begin
          return if @stop_process_messages
          message, wire = switchboard.next_message(:timeout => 1)

          wires_waiting_for_work.each { |w| send_work wire }

          case message
          when NeedWork; send_work wire
          when Result; write_result message
          else raise UnexpectedMessageError, message.inspect
          end

        rescue Telegraph::NoMessageAvailable
          retry
        rescue Exception => e
          raise unless @stop_process_messages
        end
      end
    end

    def wires_waiting_for_work
      @wires_waiting_for_work ||= Set.new
    end

    def send_work(wire)
      begin
        wire.send_message take_work
        wires_waiting_for_work.delete wire

      rescue NoWorkUnitsAvailableError
        wires_waiting_for_work.add wire

      rescue NoWorkUnitsRemainingError
        wire.send_message NoMoreWork
        wires_waiting_for_work.delete wire

      end
    end

    def stop
      @stop_process_messages = true
      operator.shutdown
      drb_server.stop_service
      @process_messages_thread.join
    end

    def self.remote_reference(address, port)
      central_command = DRbObject.new_with_uri("druby://#{address}:#{port}")
      DeepTest.logger.debug { "Connecting to DeepTest central_command at #{central_command.__drburi}" }
      central_command
    end

    class NoWorkUnitsAvailableError < StandardError; end
    class NoWorkUnitsRemainingError < StandardError; end
    class NoAgentsRunningError < StandardError; end
    class CheckIfAgentsAreStillRunning < StandardError; end
    class UnexpectedMessageError < StandardError; end
  end
end
