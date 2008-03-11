module DeepTest
  class TestTask
    def initialize(name = :deep_test)
      @name = name
      @options = Options.new({})
      self.pattern = "test/**/*_test.rb"
      yield self if block_given?
      define
    end
    
    def define
      desc "Run '#{@name}' suite using DeepTest"
      task @name do
        ruby "#{runner} '#{@options.to_command_line}'"
      end
    end

    def number_of_workers
      @options.number_of_workers
    end

    def number_of_workers=(num)
      @options.number_of_workers = num
    end

    def pattern
      @options.pattern
    end

    def pattern=(pattern)
      @options.pattern = Dir.pwd + "/" + pattern
    end

    def server_port=(port)
      @options.server_port = port
    end

    def server_port
      @options.server_port
    end

    def timeout_in_seconds=(seconds)
      @options.timeout_in_seconds = seconds
    end

    def timeout_in_seconds
      @options.timeout_in_seconds
    end

    def worker_listener=(listener)
      @options.worker_listener = listener
    end

    def worker_listener
      @options.worker_listener
    end

  private

    def runner
      File.expand_path(File.dirname(__FILE__) + "/../../script/run_test_suite.rb")
    end    
  end
end
