require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "number_of_workers is determined by options" do
      workers = LocalWorkers.new(
        Options.new(:number_of_workers => 4)
      )

      assert_equal 4, workers.number_of_workers
    end

    test "load_files simply loads each file provided" do
      workers = LocalWorkers.new(
        Options.new(:number_of_workers => 4)
      )

      workers.expects(:load).with(:file_1)
      workers.expects(:load).with(:file_2)

      workers.load_files([:file_1, :file_2])
    end

    test "start_all redirects stdout back to server" do
      worker_class = Class.new do
        def initialize(worker_num, server, listeners);  end
        def run; puts "hello from worker"; end
      end

      output = capture_stdout do
        with_drb_server_for stub(:stdout => $stdout) do |drb_server|
          options = stub :number_of_workers => 1, 
                         :server => DRbObject.new_with_uri(drb_server.uri),
                         :new_listener_list => []

          run_workers_to_completion LocalWorkers.new(options, worker_class)
        end
      end
      assert_equal "hello from worker\n", output
    end

    def with_drb_server_for(front)
      # using drbunix prevents a getaddrinfo on our host, which can take 5 seconds
      drb_server = DRb::DRbServer.new "drbunix:", front

      begin
        yield drb_server
      ensure
        drb_server.stop_service
      end
    end

    def run_workers_to_completion(workers)
      workers.start_all
      workers.wait_for_completion
    ensure
      workers.stop_all
    end
  end
end
