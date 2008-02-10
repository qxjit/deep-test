require File.dirname(__FILE__) + "/test_helper"

unit_tests do
  test "run yields name for start and finished of underlying suite" do
    suite = Test::Unit::TestSuite.new("name")
    supervised_suite = DeepTest::SupervisedTestSuite.new(suite, stub_everything)

    yielded = []
    supervised_suite.run(stub_everything) do |channel,name|
      yielded << [channel,name]
    end

    assert_equal [[Test::Unit::TestSuite::STARTED, "name"],
                  [Test::Unit::TestSuite::FINISHED, "name"]], yielded
  end

  test "run adds test suite to supervisor" do
    suite = Test::Unit::TestSuite.new("name")
    supervisor = stub_everything
    supervised_suite = DeepTest::SupervisedTestSuite.new(suite, supervisor)
    supervisor.expects(:add_tests).with(suite)
    supervised_suite.run(stub_everything) {|channel,name|}
  end


  test "run tells supervisor to read resuts with passed in results" do
    suite = Test::Unit::TestSuite.new("name")
    results = stub_everything
    supervisor = stub_everything
    supervised_suite = DeepTest::SupervisedTestSuite.new(suite, supervisor)
    supervisor.expects(:read_results).with(results)
    supervised_suite.run(results) {|channel,name|}
  end


  test "run passes progress block on to supervisor" do
    suite = Test::Unit::TestSuite.new("name")
    supervisor = stub_everything
    supervised_suite = DeepTest::SupervisedTestSuite.new(suite, supervisor)
    supervisor.stubs(:read_results).yields("from_supervisor", "event")
    yielded = []
    supervised_suite.run(stub_everything) do |channel,name|
      yielded << [channel, name]
    end

    assert_equal true, yielded.include?(["from_supervisor", "event"])
  end

  test "has same size as underlyng suite" do
    suite = Test::Unit::TestSuite.new("name")
    suite << "test"
    supervisor = stub_everything
    supervised_suite = DeepTest::SupervisedTestSuite.new(suite, supervisor)
    
    assert_equal suite.size, supervised_suite.size
  end
  
  test "defaults to using DeepTest::Supervisor" do
    DeepTest::Supervisor.stubs(:new).returns(:supervisor)
    supervised_suite = DeepTest::SupervisedTestSuite.new(stub)
    assert_equal :supervisor, supervised_suite.instance_variable_get("@supervisor")
  end
end
