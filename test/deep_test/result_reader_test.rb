require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    class FakeResult
      attr_reader :identifier
      def initialize(i) @identifier = i; end
      def ==(other) identifier == other.identifier; end
    end

    test "reads all as many results as requested" do
      blackboard = SimpleTestBlackboard.new
      1.upto(4) {|i| blackboard.write_result FakeResult.new(i)}
      work_units = {1 => "One", 2 => "Two", 3 => "Three"}
      ResultReader.new(blackboard).read(work_units) {}
      assert_equal FakeResult.new(4), blackboard.take_result
    end

    test "returns unread tests on ResultOverdueError" do
      blackboard = SimpleTestBlackboard.new
      blackboard.simulate_result_overdue_error = true
      work_units = {1 => "One"}
      ResultReader.new(blackboard).read(work_units) {}
      assert_equal({1 => "One"}, work_units)
    end

    test "yields each result" do
      blackboard = SimpleTestBlackboard.new
      1.upto(3) {|i| blackboard.write_result FakeResult.new(i)}
      results = []
      work_units = {1 => "One", 2 => "Two", 3 => "Three"}
      ResultReader.new(blackboard).read(work_units) {|r| results << r}
      assert_equal [["One", FakeResult.new(1)], 
                    ["Two", FakeResult.new(2)],
                    ["Three", FakeResult.new(3)]], 
                   results
    end

    test "keeps attempting to read results when none are available" do
      blackboard = SimpleTestBlackboard.new
      work_units = {1 => "One", 2 => "Two", 3 => "Three"}
      t = Thread.new {ResultReader.new(blackboard).read(work_units) {}}
      1.upto(4) {|i| blackboard.write_result FakeResult.new(i)}
      t.join
      assert_equal FakeResult.new(4), blackboard.take_result
    end

    test "doesn't yield empty results" do
      blackboard = SimpleTestBlackboard.new
      results = []
      t = Thread.new {ResultReader.new(blackboard).read(1 => "One") {|r| results << r}}
      blackboard.write_result FakeResult.new(1)
      t.join
      assert_equal [["One", FakeResult.new(1)]], results
    end

    test "prints output if result has output" do
      blackboard = SimpleTestBlackboard.new
      blackboard.write_result mock(:output => "output", :identifier => 1)

      out = capture_stdout do
        ResultReader.new(blackboard).read(1 => "One") {}
      end

      assert_equal "output", out
    end

    test "doesn't print any output if output is nil" do
      blackboard = SimpleTestBlackboard.new
      blackboard.write_result mock(:output => nil, :identifier => 1)

      out = capture_stdout do
        ResultReader.new(blackboard).read(1 => "One") {}
      end

      assert_equal "", out
    end

    test "prints useful error information in case of Worker::Error" do
      error = RuntimeError.new "message"
      error.set_backtrace ['a', 'b']

      blackboard = SimpleTestBlackboard.new
      blackboard.write_result Worker::Error.new("work_unit", error)


      out = capture_stdout do
        ResultReader.new(blackboard).read(1 => "One") {}
      end

      assert_equal "work_unit: message\na\nb\n", out
    end

    test "doesn't yield Worker::Error results" do
      blackboard = SimpleTestBlackboard.new
      blackboard.write_result Worker::Error.new("work_unit", RuntimeError.new)


      results = []
      capture_stdout do
        ResultReader.new(blackboard).read(1 => "One") {|r| results << r}
      end

      assert_equal [], results
    end

    test "doesn't modify original work unit hash" do
      blackboard = SimpleTestBlackboard.new
      blackboard.write_result FakeResult.new(1)
      work_units = {1 => "One"}
      ResultReader.new(blackboard).read(work_units) {} 
      assert_equal({1 => "One"}, work_units)
    end

    test "returns remaining tests that didn't have errors" do
      blackboard = SimpleTestBlackboard.new
      blackboard.write_result FakeResult.new(1)
      blackboard.write_result Worker::Error.new("work_unit", RuntimeError.new)

      work_units = {1 => "One", 2 => "Two"}

      capture_stdout do
        missing_work_units = ResultReader.new(blackboard).read(work_units) {} 
        assert_equal({2 => "Two"}, missing_work_units)
      end
    end
  end
end
