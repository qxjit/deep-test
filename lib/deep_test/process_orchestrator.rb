module DeepTest
  class ProcessOrchestrator
    def self.run(options, workers, runner)
      new(options, workers, runner).run
    end
    
    def initialize(options, workers, runner)
      @options = options
      @runner = runner
      @workers = workers
    end
    
    def run(exit_when_done = true)
      passed = false

      begin
        server = Server.start(@options)
        @options.new_listener_list.before_starting_workers
        @workers.start_all
        begin
          DeepTest.logger.debug "Loader Starting (#{$$})"
          passed = @runner.process_work_units
        ensure
          shutdown(server)
        end
      ensure
        DeepTest.logger.debug "ProcessOrchestrator: Stopping Server"
        Server.stop
      end

      Kernel.exit(passed ? 0 : 1) if exit_when_done
    end

    def shutdown(server)
      server.done_with_work

      first_exception = $!
      begin
        DeepTest.logger.debug "ProcessOrchestrator: Stopping Workers"
        @workers.stop_all
      rescue DRb::DRbConnError
        # Workers must have already stopped
      rescue Exception => e
        raise first_exception || e
      end
    end
  end
end
