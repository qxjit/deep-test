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
        DeepTest.logger.debug("SupervisedTestSuite: going to read #{count} results")

        ResultReader.new(@blackboard).read(count) do |remote_result|
          remote_result.add_to result
          yield ::Test::Unit::TestCase::FINISHED, nil if block_given?
        end
      ensure
        DeepTest.logger.debug("SupervisedTestSuite: exiting with #{count} results left")
      end
    end
  end
end
