module DeepTest
  class Worker
    def initialize(blackboard)
      @blackboard = blackboard
    end

    def run
      while test_case = @blackboard.take_test
        result = run_test_case test_case
        result = run_test_case test_case if result.failed_due_to_deadlock?
        result = Test::Unit::TestResult.new if result.failed_due_to_deadlock?
        @blackboard.write_result result
      end
    end
    
    protected
    
    def run_test_case(test_case)
      result = Test::Unit::TestResult.new
      output = capture_stdout do
        test_case.run(result) {|channel,event|}
      end
      result.output = output
      result
    end
  end
end
