require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Test
    unit_tests do
      test "add_to adds correct run_count" do
        result_1 = WorkResult.new "test_name"
        result_1.add_run
        result_1.add_run

        result_2 = ::Test::Unit::TestResult.new
        result_1.add_to result_2

        assert_equal 2, result_2.run_count
      end

      test "add_to adds correct assertion_count" do
        result_1 = WorkResult.new "test_name"
        result_1.add_assertion
        result_1.add_assertion

        result_2 = ::Test::Unit::TestResult.new
        result_1.add_to result_2

        assert_equal 2, result_2.assertion_count
      end

      test "add_to adds correct errors" do
        result_1 = WorkResult.new "test_name"
        result_1.add_error(e = ::Test::Unit::Error.new("test_name", Exception.new))

        result_2 = ::Test::Unit::TestResult.new
        result_1.add_to result_2

        assert_equal [e], result_2.instance_variable_get(:@errors)
      end


      test "add_to adds correct failures" do
        result_1 = WorkResult.new "test_name"
        result_1.add_failure(:failure)

        result_2 = ::Test::Unit::TestResult.new
        result_1.add_to result_2

        assert_equal [:failure], result_2.instance_variable_get(:@failures)
      end
      
      test "add_error wraps exceptions" do
        result = WorkResult.new "test_name"
        result.add_error ::Test::Unit::Error.new(
          "test_wraps_exceptions", 
          SomeCustomException.new("the exception message")
        )

        error = result.instance_variable_get("@errors").last
        assert_kind_of MarshallableExceptionWrapper, error.exception
      end

      test "add_to unwraps exception" do
        work_result = WorkResult.new "test_name"
        work_result.add_error ::Test::Unit::Error.new(
          "test_wraps_exceptions", 
          SomeCustomException.new("the exception message")
        )

        test_result = ::Test::Unit::TestResult.new
        work_result.add_to(test_result)

        error = test_result.instance_variable_get("@errors").last
        assert_kind_of SomeCustomException, error.exception
      end
      
      test "failed due to deadlock" do
        result = WorkResult.new "test_name"
        begin
          raise FakeDeadlockError.new
        rescue => ex
          result.add_error ::Test::Unit::Error.new("test_", ex)
        end
        assert_equal true, result.failed_due_to_deadlock?
      end
    end
  end
end
