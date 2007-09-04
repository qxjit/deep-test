require File.dirname(__FILE__) + "/test_helper"

unit_tests do
  test "defines a rake task with the name passed to the constructor" do
    DeepTest::TestTask.any_instance.stubs(:desc)
    DeepTest::TestTask.any_instance.expects(:task).with { |hash| hash.keys == [:my_task_name] }
    DeepTest::TestTask.new :my_task_name do
    end
  end
  
  test "defined task starts server and workers" do
    DeepTest::TestTask.any_instance.stubs(:desc)
    DeepTest::TestTask.any_instance.expects(:task).with { |hash| hash.values == [["deep_test:server:start","deep_test:workers:start"]] }
    DeepTest::TestTask.new :my_task_name do
    end
  end
  
  test "setting pattern" do
    task = DeepTest::TestTask.new do |t|
      t.stubs(:define)
      t.pattern = "test/**/x*_test.rb"
    end
    assert_equal "test/**/x*_test.rb", task.pattern
  end
  
  test "default pattern is test/**/*_test.rb" do
    task = DeepTest::TestTask.new do |t|
      t.stubs(:define)
    end
    assert_equal "test/**/*_test.rb", task.pattern
  end
  
  test "filters are empty" do
    task = DeepTest::TestTask.new do |t|
      t.stubs(:define)
    end
    assert_equal [], task.filters
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
  
  test "processes is set in env variable" do
    task = DeepTest::TestTask.new do |t|
      t.processes = 3
      t.stubs :desc
      t.stubs :task
    end
    assert_equal "3", ENV['DEEP_TEST_PROCESSES']
  end
end
