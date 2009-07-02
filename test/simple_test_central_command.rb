module DeepTest
  class SimpleTestCentralCommand
    include DRbTestHelp

    attr_accessor :debug, :simulate_result_overdue_error
    attr_accessor :stdout, :stderr

    def initialize
      @work_units = []
      @test_results = []
      @semaphore = Mutex.new
      @stdout = StringIO.new
      @stderr = StringIO.new
    end

    def with_drb_server(&block)
      with_drb_server_for self, &block
    end

    def take_result
      raise DeepTest::CentralCommand::ResultOverdueError if @simulate_result_overdue_error
      @semaphore.synchronize do
        log_and_return "take_result", @test_results.shift
      end
    end

    def take_work
      @semaphore.synchronize do
        log_and_return "take_work", @work_units.shift
      end
    end

    def write_result(result)
      @semaphore.synchronize do
        log_and_return "write_result", result
        @test_results.push result
      end
    end

    def write_work(work_unit)
      @semaphore.synchronize do
        log_and_return "write_work", work_unit
        @work_units.push work_unit
      end
    end

    def log_and_return(message, object)
      if debug && object
        puts "* #{message} #{object.inspect}"
      end
      object
    end
  end
end
