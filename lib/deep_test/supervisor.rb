module DeepTest
  class Supervisor
    def initialize(blackboard = DeepTest::RindaBlackboard.new)
      @blackboard = blackboard
      @count = 0
    end

    def add_tests(test_suite)
      if test_suite.respond_to? :tests
        test_suite.tests.each {|test| add_tests(test)}
      else
        @count += 1
        @blackboard.write_test test_suite
      end
    end

    def read_results(result)
      while (@count > 0 && remote_result = @blackboard.take_result)
        @count -= 1
        remote_result.add_to result
        # TODO: is this the right place for this next line? -Dan
        print remote_result.output if remote_result.output
        yield Test::Unit::TestCase::FINISHED, nil if block_given?
      end
    end
  end
end
