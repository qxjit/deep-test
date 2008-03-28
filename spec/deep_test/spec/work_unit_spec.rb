require File.dirname(__FILE__) + "/../../spec_helper"

describe DeepTest::Spec::WorkUnit do
  it_should_behave_like "sandboxed rspec_options"

  it "should run the example specified by location" do
    spec_was_run = false
    group = describe("test") do
      it("passes") {spec_was_run = true}
    end
    work_unit = DeepTest::Spec::WorkUnit.new(group.examples.first.identifier)
    work_unit.run
    spec_was_run.should == true
  end

  it "should return a Spec::WorkResult with the location and errors" do
    error = RuntimeError.new
    group = describe("test") do
      it("fails") {raise error}
    end
    id = group.examples.first.identifier
    work_unit = DeepTest::Spec::WorkUnit.new(id)
    work_unit.run.should == DeepTest::Spec::WorkResult.new(id, error, nil)
  end

  it "should preserve the original rspec_options reporter" do
    group = describe("test") do
      it("passes") {}
    end
    original_reporter = options.reporter
    work_unit = DeepTest::Spec::WorkUnit.new(group.examples.first.identifier)
    work_unit.run
    options.reporter.should == original_reporter
  end

  it "should retry examples that fail due to deadlock once" do
    example_run_count = 0
    group = describe("test") do
      it("passes") {example_run_count += 1; raise FakeDeadlockError.new if example_run_count == 1}; 
    end
    work_unit = DeepTest::Spec::WorkUnit.new(group.examples.first.identifier)
    result = work_unit.run
    example_run_count.should == 2
    result.error.should == nil
  end

  it "should move on without failing test if example fails do to deadlock more than once" do
    example_run_count = 0
    group = describe("test") do
      it("passes") {example_run_count += 1; raise FakeDeadlockError.new}; 
    end
    work_unit = DeepTest::Spec::WorkUnit.new(group.examples.first.identifier)
    result = work_unit.run
    example_run_count.should == 2
    result.error.should == nil
    result.output.should == '-deadlock-'
  end

  it "should only run examples that don't fail due to deadlock once" do
    example_run_count = 0
    group = describe("test") do
      it("passes") {example_run_count += 1; raise "Error"}
    end
    work_unit = DeepTest::Spec::WorkUnit.new(group.examples.first.identifier)
    result = work_unit.run
    example_run_count.should == 1
    result.error.message.should == "Error"
  end

  it "should provide useful description as string" do
    group = describe("my example") do
      it("passes") {}
    end
    work_unit = DeepTest::Spec::WorkUnit.new(group.examples.first.identifier)

    work_unit.to_s.should == "my example: passes"
  end
end
