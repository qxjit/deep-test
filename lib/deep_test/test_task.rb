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
          require "deep_test"
          ENV["RAILS_ENV"] = "test"
          Object.const_set "RAILS_ENV", "test"
          files = Dir.glob(ENV['DEEP_TEST_PATTERN'])
          files.each { |file| load file }
          suite = Test::Unit::AutoRunner::COLLECTORS[:objectspace].call self
          blackboard = DeepTest::RindaBlackboard.new
          supervisor = DeepTest::Supervisor.new blackboard
          supervised_suite = DeepTest::SupervisedTestSuite.new(suite, supervisor)
          require 'test/unit/ui/console/testrunner'
          Test::Unit::UI::Console::TestRunner.run(supervised_suite, Test::Unit::UI::NORMAL)
          Test::Unit.run = true
        ensure
          Rake::Task["deep_test:workers:stop"].invoke
          Rake::Task["deep_test:server:stop"].invoke
        end
      end
    end
    
    def filters
      []
    end
    
    def pattern
      @pattern || "test/**/*_test.rb"
    end
    
    def processes
      @processes ? @processes.to_i : 2
    end
  end
end
