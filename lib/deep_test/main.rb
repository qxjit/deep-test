module DeepTest
  class Main
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
        central_command = CentralCommand.start(@options)
        @options.new_listener_list.before_starting_workers
        @workers.start_all
        begin
          DeepTest.logger.debug { "Loader Starting (#{$$})" }
          passed = @runner.process_work_units
        ensure
          shutdown(central_command)
        end
      ensure
        DeepTest.logger.debug { "Main: Stopping CentralCommand" }
        CentralCommand.stop
      end

      Kernel.exit(passed ? 0 : 1) if exit_when_done
    end

    def shutdown(central_command)
      DeepTest.logger.debug { "Main: Shutting Down" }
      central_command.done_with_work

      first_exception = $!
      begin
        DeepTest.logger.debug { "Main: Stopping Workers" }
        @workers.stop_all
      rescue DRb::DRbConnError
        # Workers must have already stopped
      rescue Exception => e
        raise first_exception || e
      end
    end
  end
end
