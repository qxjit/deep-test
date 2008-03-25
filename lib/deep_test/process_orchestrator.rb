module DeepTest
  class ProcessOrchestrator
    def self.run(options, workers, runner)
      new(options, workers, runner).run
    end
    
    def initialize(options, workers, runner)
      @options = options
      @runner = runner
      @workers = workers
      @warlock = Warlock.new
    end
    
    def run(exit_when_done = true)
      passed = false

      begin
        start_server
        @options.new_listener_list.before_starting_workers
        @workers.start_all
        begin
          DeepTest.logger.debug "Loader Starting (#{$$})"
          passed = @runner.process_work_units
        ensure
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
      ensure
        DeepTest.logger.debug "ProcessOrchestrator: Stopping Server"
        @warlock.stop_all
      end

      Kernel.exit(passed ? 0 : 1) if exit_when_done
    end

    def start_server
      server_ready = false
      previous_trap = Signal.trap('USR2') {server_ready = true}

      pid = Process.pid
      @warlock.start("server") do
        DeepTest::Server.start(@options) do
          Process.kill('USR2', pid)
        end
      end

      Thread.pass until server_ready
    ensure
      Signal.trap('USR2', previous_trap)
    end
  end
end
