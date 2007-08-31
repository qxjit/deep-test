module DeepTest
  class Worker
    def initialize(blackboard)
      @blackboard = blackboard
    end

    def run
      while (test_case = @blackboard.take_test)
        result = Test::Unit::TestResult.new
        output = capture_stdout do
          test_case.run(result) {|channel,event|}
        end
        result.output = output
        @blackboard.write_result result
      end
    end
  end
end
