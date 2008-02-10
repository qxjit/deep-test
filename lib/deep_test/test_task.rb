module DeepTest
  class TestTask
    DEFAULT_NUMBER_OF_WORKERS = 2
    attr_writer :number_of_workers, :pattern

    def initialize(name = :deep_test)
      @name = name
      yield self if block_given?
      define
    end
    
    def define
      desc "Run '#{@name}' suite using DeepTest"
      task @name do
        deep_test_lib = File.expand_path(File.dirname(__FILE__) + "/..")
        runner = File.expand_path(File.dirname(__FILE__) + "/../../script/run_test_suite.rb")
        ruby "#{runner} '#{number_of_workers}' '#{pattern}'"
      end
    end
    
    def number_of_workers
      @number_of_workers ? @number_of_workers.to_i : DEFAULT_NUMBER_OF_WORKERS
    end

    def pattern
      Dir.pwd + "/" + (@pattern || "test/**/*_test.rb")
    end
  end
end
