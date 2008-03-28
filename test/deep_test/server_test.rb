require File.dirname(__FILE__) + "/../test_helper"

unit_tests do
  test "take_work returns result of push_work when it is available" do
    server = DeepTest::Server.new(DeepTest::Options.new({}))
    t = Thread.new {server.take_work}
    server.write_work :work
    assert_equal :work, t.value
  end

  test "take_result returns result of push_result when it is available" do
    server = DeepTest::Server.new(DeepTest::Options.new({}))
    t = Thread.new {server.take_result}
    server.write_result :result
    assert_equal :result, t.value
  end

  test "take_work timeouts out after configurable number of seconds" do
    server = DeepTest::Server.new(
      DeepTest::Options.new(:timeout_in_seconds => 0.01)
    )
    Thread.new {sleep 0.1; server.write_work :too_late}
    assert_raises(Timeout::Error) {server.take_work}
  end

  test "take_result timeouts out after configurable number of seconds" do
    server = DeepTest::Server.new(
      DeepTest::Options.new(:timeout_in_seconds => 0.01)
    )
    Thread.new {sleep 0.1; server.write_result :too_late}
    assert_raises(Timeout::Error) {server.take_result}
  end

  test "write_work returns nil" do
    server = DeepTest::Server.new(DeepTest::Options.new({}))
    assert_equal nil, server.write_work(:a)
  end

  test "write_result returns nil" do
    server = DeepTest::Server.new(DeepTest::Options.new({}))
    assert_equal nil, server.write_result(:a)
  end
end
