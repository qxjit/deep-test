module DeepTest
  module Test
    class SupervisedTestSuite
      def initialize(suite, blackboard)
        @suite = suite
        @blackboard = blackboard
      end

      def run(result, &progress_block)
        yield ::Test::Unit::TestSuite::STARTED, @suite.name
        count = add_tests @suite
        read_results result, count, &progress_block
        yield ::Test::Unit::TestSuite::FINISHED, @suite.name
      end

      def size
        @suite.size
      end

      def add_tests(test_suite)
        count = 0
        if test_suite.respond_to? :tests
          test_suite.tests.each do |test| 
            count += add_tests(test)
          end
        else
          count += 1
          @blackboard.write_work Test::WorkUnit.new(test_suite)
        end
        count
      end

      def read_results(result, count)
        while count > 0
          remote_result = @blackboard.take_result
          next unless remote_result
          count -= 1
          remote_result.add_to result
          # TODO: is this the right place for this next line? -Dan
          print remote_result.output if remote_result.output
          yield ::Test::Unit::TestCase::FINISHED, nil if block_given?
        end
      end
    end
  end
end
