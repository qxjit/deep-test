require File.dirname(__FILE__) + "/test_helper"

unit_tests do
  test "defines a rake task with the name passed to the constructor" do
    DeepTest::TestTask.any_instance.stubs(:desc)
    DeepTest::TestTask.any_instance.expects(:task).with(:my_task_name)
    DeepTest::TestTask.new :my_task_name do
    end
  end
  
  test "setting pattern" do
    pattern = "test/**/x*_test.rb"
    task = DeepTest::TestTask.new do |t|
      t.stubs(:define)
      t.pattern = pattern
    end
    assert_equal pattern, task.pattern[-pattern.size..-1]
  end
  
  test "default pattern is test/**/*_test.rb" do
    task = DeepTest::TestTask.new do |t|
      t.stubs(:define)
    end
    assert_equal "test/**/*_test.rb", task.pattern[-"test/**/*_test.rb".size..-1]
  end
  
  test "processes defaults to 2" do
    task = DeepTest::TestTask.new do |t|
      t.stubs(:define)
    end
    assert_equal 2, task.processes
  end
  
  test "processes can be set" do
    task = DeepTest::TestTask.new do |t|
      t.processes = 42
      t.stubs(:define)
    end
    assert_equal 42, task.processes
  end
end
