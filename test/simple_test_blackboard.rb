module DeepTest
  class SimpleTestBlackboard
    attr_accessor :debug

    def initialize
      @work_units = []
      @test_results = []
      @semaphore = Mutex.new
    end

    def take_result
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
