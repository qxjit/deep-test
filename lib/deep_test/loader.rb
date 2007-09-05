module DeepTest
  class Loader
    NO_FILTERS = Object.new.instance_eval do
      def filters; []; end;
      self
    end
    
    def self.run(args)
      require "deep_test"
      ENV["RAILS_ENV"] = "test"
      Object.const_set "RAILS_ENV", "test"
      Dir.glob(ARGV.first).each { |file| load file }
      suite = Test::Unit::AutoRunner::COLLECTORS[:objectspace].call NO_FILTERS
      blackboard = DeepTest::RindaBlackboard.new
      supervisor = DeepTest::Supervisor.new blackboard
      supervised_suite = DeepTest::SupervisedTestSuite.new(suite, supervisor)
      require 'test/unit/ui/console/testrunner'
      result = Test::Unit::UI::Console::TestRunner.run(supervised_suite, Test::Unit::UI::NORMAL)
      Test::Unit.run = true
      return result.passed?
    end 
  end
end

if __FILE__ == $0
  exit DeepTest::Loader.run(ARGV)
end
