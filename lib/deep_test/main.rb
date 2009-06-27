module DeepTest
  class Main
    def self.run(options, deployment, runner)
      new(options, deployment, runner).run
    end
    
    def initialize(options, deployment, runner)
      @options = options
      @runner = runner
      @deployment = deployment
    end
    
    def run(exit_when_done = true)
      passed = false

      begin
        central_command = CentralCommand.start(@options)
        @options.new_listener_list.before_starting_workers
        @deployment.start_all
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
        @deployment.stop_all
      rescue DRb::DRbConnError
        # Workers must have already stopped
      rescue Exception => e
        raise first_exception || e
      end
    end
  end
end
