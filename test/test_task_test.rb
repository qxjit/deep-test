require File.dirname(__FILE__) + "/test_helper"

module DeepTest
  unit_tests do
    test "defines a rake task with the name passed to the constructor" do
      TestTask.any_instance.stubs(:desc)
      TestTask.any_instance.expects(:task).with(:my_task_name)
      TestTask.new :my_task_name do
      end
    end
    
    test "setting pattern" do
      pattern = "test/**/x*_test.rb"
      task = TestTask.new do |t|
        t.stubs(:define)
        t.pattern = pattern
      end
      assert_equal pattern, task.pattern[-pattern.size..-1]
    end
    
    test "default pattern is test/**/*_test.rb" do
      task = TestTask.new do |t|
        t.stubs(:define)
      end
      assert_equal "test/**/*_test.rb", task.pattern[-"test/**/*_test.rb".size..-1]
    end
    
    test "default libs is ['lib']" do
      task = TestTask.new do |t|
        t.stubs(:define)
      end
      assert_equal ["lib"], task.libs
    end

    test "can add to libs" do
      task = TestTask.new do |t|
        t.libs << "test"
        t.stubs(:define)
      end
      assert_equal ["lib", "test"], task.libs
    end
    
    test "define passes the -I option to the call to ruby" do
      task = TestTask.new do |t|
        t.libs << "test"
      end
      task.expects(:ruby).with(includes("-Ilib:test"))
      Rake::Task["deep_test"].instance_variable_get("@actions").last.call
    end

    test "define does not pass the -I option to the call to ruby if there are no directories to add to the load path" do
      task = TestTask.new do |t|
        t.libs = []
      end
      task.expects(:ruby).with(Not(includes("-I")))
      Rake::Task["deep_test"].instance_variable_get("@actions").last.call
    end
    
    test "number_of_workers defaults to count from CpuInfo" do
      task = TestTask.new do |t|
        t.stubs(:define)
      end
      CpuInfo.expects(:new).returns stub(:count => 2)
      assert_equal 2, task.number_of_workers
    end
    
    test "number_of_workers can be set" do
      task = TestTask.new do |t|
        t.number_of_workers = 42
        t.stubs(:define)
      end
      assert_equal 42, task.number_of_workers
    end
  end
end
