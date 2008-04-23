module DeepTest
  class Server
    def self.start(options)
      server = new(options)
      DRb.start_service("druby://0.0.0.0:#{options.server_port}", server)
      DeepTest.logger.info "Started DeepTest service at #{DRb.uri}"
      server
    end

    def self.stop
      DRb.stop_service
    end

    def self.remote_reference(address, port)
      DRb.start_service
      blackboard = DRbObject.new_with_uri("druby://#{address}:#{port}")
      DeepTest.logger.debug "Connecting to DeepTest server at #{blackboard.__drburi}"
      blackboard
    end

    def initialize(options)
      @options = options
      @work_queue = Queue.new
      @result_queue = Queue.new

      if Metrics::Gatherer.enabled?
        require File.dirname(__FILE__) + "/metrics/queue_lock_wait_time_measurement"
        @work_queue.extend Metrics::QueueLockWaitTimeMeasurement
        @result_queue.extend Metrics::QueueLockWaitTimeMeasurement
        Metrics::Gatherer.section("server queue lock wait times") do |s|
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
      Timeout.timeout(@options.timeout_in_seconds) do
        @result_queue.pop
      end
    end

    def take_work
      raise NoWorkUnitsRemainingError if @done_with_work

      @work_queue.pop(true)
    rescue ThreadError => e
      if e.message == "queue empty"
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

    class NoWorkUnitsAvailableError < StandardError; end
    class NoWorkUnitsRemainingError < StandardError; end
  end
end
