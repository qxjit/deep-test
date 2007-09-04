module DeepTest
  class TestTask
    attr_writer :pattern, :processes

    def initialize(name = :deep_test)
      @name = name
      yield self if block_given?
      define
    end
    
    def define
      ENV['DEEP_TEST_PATTERN'] = Dir.pwd + "/" + pattern
      ENV['DEEP_TEST_PROCESSES'] = processes.to_s
      desc "Run '#{@name}' suite using DeepTest"
      task @name => %w[deep_test:server:start deep_test:workers:start] do
        begin
          loader = File.expand_path(File.dirname(__FILE__) + "/loader.rb")
          deep_test_lib = File.expand_path(File.dirname(__FILE__) + "/..")
          ruby "-I#{deep_test_lib} #{loader} '#{pattern}'"
        ensure
          Rake::Task["deep_test:workers:stop"].invoke
          Rake::Task["deep_test:server:stop"].invoke
        end
      end
    end
    
    def pattern
      @pattern || "test/**/*_test.rb"
    end
    
    def processes
      @processes ? @processes.to_i : 2
    end
  end
end
