require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "returns passed result for passing test" do
    work_unit = DeepTest::Test::WorkUnit.new TestFactory.passing_test
    assert_equal true, work_unit.run.passed?
  end

  test "returns failed result for failing test" do
    work_unit = DeepTest::Test::WorkUnit.new TestFactory.failing_test
    assert_equal false, work_unit.run.passed?
  end

  test "capturing stdout" do
    work_unit = DeepTest::Test::WorkUnit.new TestFactory.passing_test_with_stdout
    assert_equal "message printed to stdout", work_unit.run.output
  end
  
  test "retry on deadlock" do
    work_unit = DeepTest::Test::WorkUnit.new TestFactory.deadlock_once_test
    result = work_unit.run
    assert_equal 0, result.error_count
    assert_equal 0, result.failure_count
    assert_equal 1, result.assertion_count
  end
  
  test "skip on deadlock twice" do
    work_unit = DeepTest::Test::WorkUnit.new TestFactory.deadlock_always_test
    result = work_unit.run
    assert_equal 0, result.error_count
    assert_equal 0, result.failure_count
    assert_equal 0, result.assertion_count
  end

  test "equality is based on test_case" do
    test_case_1 = TestFactory.passing_test
    test_case_2 = TestFactory.failing_test
    assert_equal DeepTest::Test::WorkUnit.new(test_case_1),
                 DeepTest::Test::WorkUnit.new(test_case_1)

    assert_not_equal DeepTest::Test::WorkUnit.new(test_case_1),
                     DeepTest::Test::WorkUnit.new(test_case_2)
  end

  test "to_s is delegated to test case" do
    test_case = TestFactory.passing_test
    assert_equal test_case.to_s, DeepTest::Test::WorkUnit.new(test_case).to_s
  end
end
