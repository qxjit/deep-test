module DeepTest
  class ProcessOrchestrator
    def self.run(options, runner)
      new(options, runner).run
    end
    
    def initialize(options, runner)
      @options = options
      @runner = runner
    end
    
    def run
      stop_zombie_warlocks
      start_warlock_server
      start_all_workers
      start_loader
      wait_for_loader_to_be_done
      exit_process        
    ensure
      stop_all_warlocks
    end
    
  private

    def exit_process
      Kernel.exit($?.success? ? 0 : 1)
    end

    def start_all_workers
      each_worker do |worker_num|
        start_worker(worker_num) do
          reseed_random_numbers
          reconnect_to_database
          worker = DeepTest::Worker.new(worker_num,
                                        RindaBlackboard.new(@options), 
                                        @options.new_worker_listener)
          worker.run
        end
      end        
    end

    def reconnect_to_database
      ActiveRecord::Base.connection.reconnect! if defined?(ActiveRecord::Base)
    end

    def start_worker(worker_num, &blk)
      @warlock.start("worker #{worker_num}", &blk)
    end

    def reseed_random_numbers
      srand
    end

    def wait_for_loader_to_be_done
      Process.wait(@loader_pid)
    end

    def start_warlock_server
      server_ready = false
      previous_trap = Signal.trap('USR2') {server_ready = true}

      pid = Process.pid
      @warlock.start("server") do
        DeepTest::Server.start do
          Process.kill('USR2', pid)
        end
      end

      Thread.pass until server_ready
    ensure
      Signal.trap('USR2', previous_trap)
    end

    def stop_all_warlocks
      @warlock.stop_all if @warlock
    end

    def each_worker
      @options.number_of_workers.to_i.times { |worker_num| yield worker_num }
    end

    def stop_zombie_warlocks
      @warlock = DeepTest::Warlock.new
      Signal.trap("HUP") { warlock.stop_all; exit 0 }
    end

    def start_loader
      @loader_pid = fork do
        DeepTest.logger.debug "Loader Starting (#{$$})"
        passed = @runner.process_work_units
        exit(passed ? 0 : 1)
      end
    end

  end
end
