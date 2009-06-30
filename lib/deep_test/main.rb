module DeepTest
  class Main
    def initialize(options, deployment, runner, central_command = nil)
      @options = options
      @deployment = deployment
      @runner = runner
      @central_command = central_command || CentralCommand.start(options)
    end

    def load_files(files)
      @deployment.load_files files
    end
    
    def run(exit_when_done = true)
      passed = false

      begin
        @options.new_listener_list.before_starting_agents
        @deployment.deploy_agents
        begin
          DeepTest.logger.debug { "Loader Starting (#{$$})" }
          passed = @runner.process_work_units
        ensure
          shutdown
        end
      ensure
        DeepTest.logger.debug { "Main: Stopping CentralCommand" }
        CentralCommand.stop
      end

      Kernel.exit(passed ? 0 : 1) if exit_when_done
    end

    def shutdown
      DeepTest.logger.debug { "Main: Shutting Down" }
      @central_command.done_with_work

      first_exception = $!
      begin
        DeepTest.logger.debug { "Main: Stopping Agents" }
        @deployment.terminate_agents
      rescue DRb::DRbConnError
        # Agents must have already stopped
      rescue Exception => e
        raise first_exception || e
      end
    end
  end
end
