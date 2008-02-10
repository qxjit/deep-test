module DeepTest
  class SupervisedTestSuite
    def initialize(suite, supervisor = DeepTest::Supervisor.new)
      @suite = suite
      @supervisor = supervisor
    end

    def run(result, &progress_block)
      yield Test::Unit::TestSuite::STARTED, @suite.name
      @supervisor.add_tests @suite
      @supervisor.read_results result, &progress_block
      yield Test::Unit::TestSuite::FINISHED, @suite.name
    end

    def size
      @suite.size
    end
  end
end
