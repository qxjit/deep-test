require File.dirname(__FILE__) + "/../../spec_helper"

describe DeepTest::Spec::WorkUnit do
  it_should_behave_like "sandboxed rspec_options"

  it "should run the example specified by location" do
    spec_was_run = false
    line = nil
    Class.new(Spec::Example::ExampleGroup) do
      it("passes") {spec_was_run = true}; line = __LINE__
    end
    work_unit = DeepTest::Spec::WorkUnit.new(__FILE__, line)
    work_unit.run
    spec_was_run.should == true
  end

  it "should return a Spec::WorkResult with the location and errors" do
    line = nil
    error = RuntimeError.new
    Class.new(Spec::Example::ExampleGroup) do
      it("fails") {raise error}; line = __LINE__
    end
    work_unit = DeepTest::Spec::WorkUnit.new(__FILE__, line)
    work_unit.run.should == DeepTest::Spec::WorkResult.new(__FILE__, line, "fails", error, nil)
  end

  it "should preserve the original rspec_options reporter" do
    line = nil
    Class.new(Spec::Example::ExampleGroup) do
      it("passes") {}; line = __LINE__
    end
    original_reporter = options.reporter
    work_unit = DeepTest::Spec::WorkUnit.new(__FILE__, line)
    work_unit.run
    options.reporter.should == original_reporter
  end

  it "should retry examples that fail due to deadlock once" do
    line = nil
    example_run_count = 0
    Class.new(Spec::Example::ExampleGroup) do
      it("passes") {example_run_count += 1; raise FakeDeadlockError.new if example_run_count == 1}; 
      line = __LINE__ - 1
    end
    original_reporter = options.reporter
    work_unit = DeepTest::Spec::WorkUnit.new(__FILE__, line)
    result = work_unit.run
    example_run_count.should == 2
    result.error.should == nil
  end

  it "should move on without failing test if example fails do to deadlock more than once" do
    line = nil
    example_run_count = 0
    Class.new(Spec::Example::ExampleGroup) do
      it("passes") {example_run_count += 1; raise FakeDeadlockError.new}; 
      line = __LINE__ - 1
    end
    original_reporter = options.reporter
    work_unit = DeepTest::Spec::WorkUnit.new(__FILE__, line)
    result = work_unit.run
    example_run_count.should == 2
    result.error.should == nil
    result.output.should == '-deadlock-'
  end

  it "should only run examples that don't fail due to deadlock once" do
    line = nil
    example_run_count = 0
    Class.new(Spec::Example::ExampleGroup) do
      it("passes") {example_run_count += 1; raise "Error"}; line = __LINE__
    end
    original_reporter = options.reporter
    work_unit = DeepTest::Spec::WorkUnit.new(__FILE__, line)
    result = work_unit.run
    example_run_count.should == 1
    result.error.message.should == "Error"
  end
end
