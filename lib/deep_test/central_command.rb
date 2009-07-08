module DeepTest
  class CentralCommand
    attr_reader :medic

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

    def stdout
      $stdout
    end

    def stderr
      $stderr
    end

    def self.start(options)
      central_command = new(options)
      server = DRb::DRbServer.new("druby://0.0.0.0:#{options.server_port || 0}", central_command)
      DeepTest.logger.info { "Started DeepTest service at #{server.uri}" }
      options.server_port = URI.parse(server.uri).port
      central_command
    end

    def self.stop
      DRb.stop_service
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
  end
end
