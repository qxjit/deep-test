require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    class FakeResult
      attr_reader :identifier
      def initialize(i) @identifier = i; end
      def ==(other) identifier == other.identifier; end
    end

    test "reads all as many results as requested" do
      central_command = TestCentralCommand.start Options.new({})
      1.upto(4) {|i| central_command.write_result FakeResult.new(i)}
      work_units = {1 => "One", 2 => "Two", 3 => "Three"}
      ResultReader.new(central_command).read(work_units) {}
      assert_equal FakeResult.new(4), central_command.take_result
    end

    test "returns unread tests on NoAgentsRunningError" do
      central_command = TestCentralCommand.start Options.new({})
      work_units = {1 => "One"}
      FailureMessage.expects(:show)
      ResultReader.new(central_command).read(work_units) {}
      assert_equal({1 => "One"}, work_units)
    end

    test "yields each result" do
      central_command = TestCentralCommand.start Options.new({})
      1.upto(3) {|i| central_command.write_result FakeResult.new(i)}
      results = []
      work_units = {1 => "One", 2 => "Two", 3 => "Three"}
      ResultReader.new(central_command).read(work_units) {|r| results << r}
      assert_equal [["One", FakeResult.new(1)], 
                    ["Two", FakeResult.new(2)],
                    ["Three", FakeResult.new(3)]], 
                   results
    end

    test "keeps attempting to read results when none are available" do
      central_command = TestCentralCommand.start Options.new({})
      work_units = {1 => "One", 2 => "Two", 3 => "Three"}
      t = Thread.new {ResultReader.new(central_command).read(work_units) {}}
      1.upto(4) {|i| central_command.write_result FakeResult.new(i)}
      t.join
      assert_equal FakeResult.new(4), central_command.take_result
    end

    test "doesn't yield empty results" do
      central_command = TestCentralCommand.start Options.new({})
      results = []
      t = Thread.new {ResultReader.new(central_command).read(1 => "One") {|r| results << r}}
      central_command.write_result FakeResult.new(1)
      t.join
      assert_equal [["One", FakeResult.new(1)]], results
    end

    test "prints output if result has output" do
      central_command = TestCentralCommand.start Options.new({})
      central_command.write_result mock(:output => "output", :identifier => 1)

      out = capture_stdout do
        ResultReader.new(central_command).read(1 => "One") {}
      end

      assert_equal "output", out
    end

    test "doesn't print any output if output is nil" do
      central_command = TestCentralCommand.start Options.new({})
      central_command.write_result mock(:output => nil, :identifier => 1)

      out = capture_stdout do
        ResultReader.new(central_command).read(1 => "One") {}
      end

      assert_equal "", out
    end

    test "prints useful error information in case of Agent::Error" do
      error = RuntimeError.new "message"
      error.set_backtrace ['a', 'b']

      central_command = TestCentralCommand.start Options.new({})
      central_command.write_result Agent::Error.new("work_unit", error)


      out = capture_stdout do
        ResultReader.new(central_command).read(1 => "One") {}
      end

      assert_equal "work_unit: message\na\nb\n", out
    end

    test "doesn't yield Agent::Error results" do
      central_command = TestCentralCommand.start Options.new({})
      central_command.write_result Agent::Error.new("work_unit", RuntimeError.new)


      results = []
      capture_stdout do
        ResultReader.new(central_command).read(1 => "One") {|r| results << r}
      end

      assert_equal [], results
    end

    test "doesn't modify original work unit hash" do
      central_command = TestCentralCommand.start Options.new({})
      central_command.write_result FakeResult.new(1)
      work_units = {1 => "One"}
      ResultReader.new(central_command).read(work_units) {} 
      assert_equal({1 => "One"}, work_units)
    end

    test "returns remaining tests that didn't have errors" do
      central_command = TestCentralCommand.start Options.new({})
      central_command.write_result FakeResult.new(1)
      central_command.write_result Agent::Error.new("work_unit", RuntimeError.new)

      work_units = {1 => "One", 2 => "Two"}

      capture_stdout do
        missing_work_units = ResultReader.new(central_command).read(work_units) {} 
        assert_equal({2 => "Two"}, missing_work_units)
      end
    end
  end
end
