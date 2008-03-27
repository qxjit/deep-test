require File.dirname(__FILE__) + "/../test_helper"

unit_tests do
  test "reads all as many results as requested" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    1.upto(4) {|i| blackboard.write_result i}
    DeepTest::ResultReader.new(blackboard).read(3) {}
    assert_equal 4, blackboard.take_result
  end

  test "yields each result" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    1.upto(3) {|i| blackboard.write_result i}
    results = []
    DeepTest::ResultReader.new(blackboard).read(3) {|r| results << r}
    assert_equal [1, 2, 3], results
  end

  test "keeps attempting to read results when none are available" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    t = Thread.new {DeepTest::ResultReader.new(blackboard).read(3) {}}
    1.upto(4) {|i| blackboard.write_result i}
    t.join
    assert_equal 4, blackboard.take_result
  end

  test "doesn't yield results" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    results = []
    t = Thread.new {DeepTest::ResultReader.new(blackboard).read(1) {|r| results << r}}
    blackboard.write_result 1
    t.join
    assert_equal [1], results
  end

  test "prints output if result has output" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    blackboard.write_result mock(:output => "output")

    out = capture_stdout do
      DeepTest::ResultReader.new(blackboard).read(1) {}
    end

    assert_equal "output", out
  end

  test "doesn't print any output if output is nil" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    blackboard.write_result mock(:output => nil)

    out = capture_stdout do
      DeepTest::ResultReader.new(blackboard).read(1) {}
    end

    assert_equal "", out
  end

  test "prints useful error information in case of Worker::Error" do
    error = RuntimeError.new "message"
    error.set_backtrace ['a', 'b']

    blackboard = DeepTest::SimpleTestBlackboard.new
    blackboard.write_result DeepTest::Worker::Error.new("work_unit", error)


    out = capture_stdout do
      DeepTest::ResultReader.new(blackboard).read(1) {}
    end

    assert_equal "work_unit: message\na\nb\n", out
  end

  test "doesn't yield Worker::Error results" do
    blackboard = DeepTest::SimpleTestBlackboard.new
    blackboard.write_result DeepTest::Worker::Error.new("work_unit", RuntimeError.new)


    results = []
    capture_stdout do
      DeepTest::ResultReader.new(blackboard).read(1) {|r| results << r}
    end

    assert_equal [], results
  end
end
