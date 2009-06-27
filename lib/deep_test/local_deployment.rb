module DeepTest
  class LocalDeployment
    def initialize(options, worker_class = DeepTest::Worker)
      @options = options
      @warlock = Warlock.new
      @worker_class = worker_class
    end

    def load_files(files)
      files.each {|f| load f}
    end

    def central_command
      @options.central_command
    end

    def start_all
      each_worker do |worker_num|
        start_worker(worker_num) do
          ProxyIO.replace_stdout_stderr!(central_command.stdout, central_command.stderr) do
            reseed_random_numbers
            reconnect_to_database
            worker = @worker_class.new(worker_num,
                                      central_command, 
                                      @options.new_listener_list)
            worker.run
          end
        end
      end        
    end

    def stop_all
      @warlock.stop_all
    end

    def wait_for_completion
      @warlock.wait_for_all_to_finish
    end

    def number_of_workers
      @options.number_of_workers
    end

    private

    def reconnect_to_database
      ActiveRecord::Base.connection.reconnect! if defined?(ActiveRecord::Base)
    end

    def start_worker(worker_num, &blk)
      @warlock.start("worker #{worker_num}", &blk)
    end

    def reseed_random_numbers
      srand
    end

    def each_worker
      number_of_workers.to_i.times { |worker_num| yield worker_num }
    end
  end
end
