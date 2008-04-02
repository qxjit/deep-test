module DeepTest
  class Server
    def self.start(options)
      DRb.start_service("druby://0.0.0.0:#{options.server_port}", new(options))
      DeepTest.logger.info "Started DeepTest service at #{DRb.uri}"
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
    end

    def take_result
      Timeout.timeout(@options.timeout_in_seconds) do
        @result_queue.pop
      end
    end

    def take_work
      Timeout.timeout(@options.timeout_in_seconds) do
        @work_queue.pop
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
  end
end
