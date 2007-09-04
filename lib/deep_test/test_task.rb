module DeepTest
  class TestTask
    attr_writer :pattern, :processes

    def initialize(name = :deep_test)
      @name = name
      yield self if block_given?
      define
    end
    
    def define
      desc "Run '#{@name}' suite using DeepTest"
      task @name => %w[deep_test:server:start] do
        begin
          deep_test_lib = File.expand_path(File.dirname(__FILE__) + "/..")
          
          # workers
          starter = File.expand_path(File.dirname(__FILE__) + "/start_workers.rb")
          ruby "-I#{deep_test_lib} #{starter} '#{processes}' '#{pattern}'"

          # loader
          loader = File.expand_path(File.dirname(__FILE__) + "/loader.rb")
          ruby "-I#{deep_test_lib} #{loader} '#{pattern}'"
        ensure
          Rake::Task["deep_test:workers:stop"].invoke
          Rake::Task["deep_test:server:stop"].invoke
        end
      end
    end
    
    def pattern
      Dir.pwd + "/" + (@pattern || "test/**/*_test.rb")
    end
    
    def processes
      @processes ? @processes.to_i : 2
    end
  end
end
