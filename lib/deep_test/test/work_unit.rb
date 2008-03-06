module DeepTest
  module Test
    class WorkUnit
      def initialize(test_case)
        @test_case = test_case
      end

      def run
        result = run_without_deadlock_protection 
        result = run_without_deadlock_protection if result.failed_due_to_deadlock?
        if result.failed_due_to_deadlock?
          result = ::Test::Unit::TestResult.new
          result.add_run
          result.output = "-deadlock-"
        end
        result
      end

      def ==(other)
        return false unless other.class == self.class
        @test_case == other.instance_variable_get(:@test_case)
      end

      protected

      def run_without_deadlock_protection
        result = ::Test::Unit::TestResult.new
        output = capture_stdout do
          @test_case.run(result) {|channel,event|}
        end
        result.output = output
        result
      end
    end
  end
end
