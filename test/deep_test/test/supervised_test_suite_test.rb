require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "run yields name for start and finished of underlying suite" do
    suite = Test::Unit::TestSuite.new("name")
    supervised_suite = DeepTest::Test::SupervisedTestSuite.new(suite, DeepTest::SimpleTestBlackboard.new)

    yielded = []
    supervised_suite.run(stub_everything) do |channel,name|
      yielded << [channel,name]
    end

    assert_equal [[Test::Unit::TestSuite::STARTED, "name"],
                  [Test::Unit::TestSuite::FINISHED, "name"]], yielded
  end

  test "run adds tests to blackboard and reads results" do
    test_case_class = Class.new(Test::Unit::TestCase) do
      test("1") {}
      test("2") {assert_equal true, false}
    end
    blackboard = DeepTest::SimpleTestBlackboard.new
    supervised_suite = DeepTest::Test::SupervisedTestSuite.new(test_case_class.suite, blackboard)
    result = Test::Unit::TestResult.new

    worker = ThreadWorker.new(blackboard, 2)
    Timeout.timeout(5) do
      supervised_suite.run(result) {}
    end
    worker.wait_until_done

    assert_equal 2, result.run_count
    assert_equal 1, result.failure_count
  end

  test "run yields test case finished events" do
    test_case_class = Class.new(Test::Unit::TestCase) do
      test("1") {}
    end

    blackboard = DeepTest::SimpleTestBlackboard.new
    supervised_suite = DeepTest::Test::SupervisedTestSuite.new(test_case_class.suite, blackboard)

    yielded = []

    worker = ThreadWorker.new(blackboard, 1)
    Timeout.timeout(5) do
      supervised_suite.run(stub_everything) do |channel,name|
        yielded << [channel, name]
      end
    end
    worker.wait_until_done

    assert_equal true, yielded.include?([::Test::Unit::TestCase::FINISHED, nil])
  end

  test "has same size as underlying suite" do
    suite = Test::Unit::TestSuite.new("name")
    suite << "test"
    supervised_suite = DeepTest::Test::SupervisedTestSuite.new(suite, DeepTest::SimpleTestBlackboard.new)
    
    assert_equal suite.size, supervised_suite.size
  end
end
