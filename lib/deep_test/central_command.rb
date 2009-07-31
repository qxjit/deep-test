require 'set'

module DeepTest
  class CentralCommand
    attr_reader :operator
    attr_reader :switchboard

    def initialize(options)
      @options = options
      @work_queue = Queue.new
      @results_mutex = Mutex.new
      @results_condvar = ConditionVariable.new
      @results = []

      if Metrics::Gatherer.enabled?
        require File.dirname(__FILE__) + "/metrics/queue_lock_wait_time_measurement"
        @work_queue.extend Metrics::QueueLockWaitTimeMeasurement
        Metrics::Gatherer.section("central_command queue lock wait times") do |s|
          s.measurement("work queue total pop wait time", @work_queue.total_pop_time)
          s.measurement("work queue total push wait time", @work_queue.total_push_time)
        end
      end
    end

    def done_with_work
      @done_with_work = true
    end

    def take_result
      @results_mutex.synchronize do
        loop do
          if @results.any?
            return @results.shift
          else
            @results_condvar.wait @results_mutex
            raise NoAgentsRunningError unless @results.any? || @switchboard.any_live_wires?
          end
        end
      end
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
      @results_mutex.synchronize do
        @results << result
        @results_condvar.signal
      end
    end

    def write_work(work_unit)
      @work_queue.push work_unit
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
      @switchboard = Telegraph::Switchboard.new
      @operator = Telegraph::Operator.listen("0.0.0.0", 0, @switchboard)
      @options.server_port = @operator.port
      @process_messages_thread = Thread.new { process_messages }

      DeepTest.logger.info { "Started DeepTest service on port #{@operator.port}" }
    end

    unless defined?(NeedWork)
      NeedWork = "NeedWork" 
      NoMoreWork = "NoMoreWork"
      module Result; end
      module Operation; end
    end

    def process_messages
      loop do
        begin
          return if @stop_process_messages
          wires_waiting_for_work.each { |w| send_work w }

          @results_mutex.synchronize do
            # make take_result wake up and check if any agents are running
            @results_condvar.signal
          end

          message, wire = switchboard.next_message(:timeout => 0.5)

          case message.body
          when NeedWork
            send_work wire
          when Result 
            write_result message.body
            send_work wire
          when Operation
            message.body.execute
          else 
            raise UnexpectedMessageError, message.inspect
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
        wire.send_message take_work, :need_ack => true
        wires_waiting_for_work.delete wire

      rescue NoWorkUnitsAvailableError
        put_abandonded_work_back_on_the_queue
        wires_waiting_for_work.add wire

      rescue NoWorkUnitsRemainingError
        wire.send_message NoMoreWork
        wires_waiting_for_work.delete wire

      end
    end

    def put_abandonded_work_back_on_the_queue
      closed_wires = switchboard.using_wires { |wires| wires.select {|w| w.closed? }}
      closed_wires.each do |wire|
        wire.unacked_messages.each do |m|
          write_work m.body
          switchboard.drop_wire wire
        end
      end
    end

    def stop
      @stop_process_messages = true
      operator.shutdown
      @process_messages_thread.join
    end

    class NoWorkUnitsAvailableError < StandardError; end
    class NoWorkUnitsRemainingError < StandardError; end
    class NoAgentsRunningError < StandardError; end
    class CheckIfAgentsAreStillRunning < StandardError; end
    class UnexpectedMessageError < StandardError; end
  end
end
