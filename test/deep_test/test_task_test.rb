require File.dirname(__FILE__) + '/../test_helper'

unit_tests do
  test "should support setting timeout_in_seconds" do
    t = DeepTest::TestTask.new :deep_test do |t|
      t.stubs(:desc)
      t.stubs(:task)
      t.timeout_in_seconds = 20
    end
    assert_equal 20, t.instance_variable_get(:@options).timeout_in_seconds
    assert_equal 20, t.timeout_in_seconds
  end

  test "should support setting distributed_server" do
    t = DeepTest::TestTask.new :deep_test do |t|
      t.stubs(:desc)
      t.stubs(:task)
      t.distributed_server = "uri"
    end
    assert_equal "uri", t.instance_variable_get(:@options).distributed_server
    assert_equal "uri", t.distributed_server
  end

  test "should support worker_listener" do
    t = DeepTest::TestTask.new :deep_test do |t|
      t.stubs(:desc)
      t.stubs(:task)
      t.worker_listener = "A"
    end
    assert_equal "A", t.instance_variable_get(:@options).worker_listener
    assert_equal "A", t.worker_listener
  end

  test "should support server_port" do
    t = DeepTest::TestTask.new :deep_test do |t|
      t.stubs(:desc)
      t.stubs(:task)
      t.server_port = 10
    end
    assert_equal 10, t.instance_variable_get(:@options).server_port
    assert_equal 10, t.server_port
  end
end
