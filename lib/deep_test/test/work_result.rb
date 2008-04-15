module DeepTest
  module Test
    class WorkResult < ::Test::Unit::TestResult
      attr_accessor :output

      def add_to(result)
        @failures.each {|e| result.add_failure(e)}
        @errors.each {|e| result.add_error(e)}
        assertion_count.times {result.add_assertion}
        run_count.times {result.add_run}
      end

      def add_error(error)
        error.make_exception_marshallable
        super(error)
      end
      
      def failed_due_to_deadlock?
        @errors.any? && DeepTest::DeadlockDetector.due_to_deadlock?(@errors.last)
      end
    end
  end
end
