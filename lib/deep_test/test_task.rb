require 'test/unit/ui/console/testrunner'

module DeepTest
  class TestTask
    attr_accessor :pattern

    def initialize(name = :test)
      @name = name
      yield self if block_given?
      define
    end
    
    def define
      ENV['DEEP_TEST_PATTERN'] = Dir.pwd + "/" + pattern
      desc "Run '#{@name}' suite using DeepTest"
      task @name => %w[deep_test:server:start deep_test:workers:start] do
        begin
          files = Dir.glob(ENV['DEEP_TEST_PATTERN'])
          files.each { |file| load file }
          suite = Test::Unit::AutoRunner::COLLECTORS[:objectspace].call self
          blackboard = DeepTest::RindaBlackboard.new
          supervisor = DeepTest::Supervisor.new blackboard
          supervised_suite = DeepTest::SupervisedTestSuite.new(suite, supervisor)
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
  end
end
