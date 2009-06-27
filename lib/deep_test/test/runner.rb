module DeepTest
  module Test
    class Runner
      unless defined?(NO_FILTERS)
        NO_FILTERS = Object.new.instance_eval do
          def filters; []; end;
          self
        end
      end

      def initialize(options)
        @options = options
      end

      def process_work_units
        suite = ::Test::Unit::AutoRunner::COLLECTORS[:objectspace].call NO_FILTERS
        supervised_suite = DeepTest::Test::SupervisedTestSuite.new(suite, @options.central_command)
        require 'test/unit/ui/console/testrunner'
        result = ::Test::Unit::UI::Console::TestRunner.run(supervised_suite, ::Test::Unit::UI::NORMAL)
        result.passed?
      end
    end
  end
end
