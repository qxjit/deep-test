module DeepTest
  class LocalWorkers
    def initialize(options)
      @options = options
      @warlock = Warlock.new
    end

    def load_files(files)
      files.each {|f| load f}
    end

    def server
      @options.server
    end

    def start_all
      each_worker do |worker_num|
        start_worker(worker_num) do
          reseed_random_numbers
          reconnect_to_database
          worker = DeepTest::Worker.new(worker_num,
                                        server, 
                                        @options.new_listener_list)
          worker.run
        end
      end        
    end

    def stop_all
      @warlock.stop_all
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
