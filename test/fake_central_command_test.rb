require File.dirname(__FILE__) + "/test_helper"

module DeepTest
  unit_tests do
    test "a test that is put on can be taken off later" do
      central_command = FakeCentralCommand.new
      test_case = TestFactory.passing_test
      central_command.write_work test_case
      assert_equal test_case, central_command.take_work
    end

    test "taking a test when all have been taken returns nil" do
      central_command = FakeCentralCommand.new
      test_case = TestFactory.passing_test
      central_command.write_work test_case
      central_command.take_work
      assert_nil central_command.take_work
    end

    test "a result that is put on can be taken off later" do
      central_command = FakeCentralCommand.new
      result = TestFactory.passed_result
      central_command.write_result result
      assert_equal result, central_command.take_result
    end

    test "taking a result when all have been taken returns nil" do
      central_command = FakeCentralCommand.new
      result = TestFactory.passed_result
      central_command.write_result result
      central_command.take_result
      assert_nil central_command.take_result
    end
  end
end
