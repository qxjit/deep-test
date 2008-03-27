require File.dirname(__FILE__) + "/../../../spec_helper"

describe Spec::Runner::Reporter do
  it_should_behave_like "sandboxed rspec_options"

  it "should be able to handle a failure without having any example groups" do
    example_group = describe("test") do
      it("example") {}
    end
    example = example_group.examples.first
    reporter = Spec::Runner::Reporter.new(options)
    lambda {
      reporter.failure(example,RuntimeError.new)
    }.should_not raise_error
  end

  it "should be able to handle a pending example without having any example groups" do
    example_group = describe("test") do
      it("example") {pending}
    end
    example = example_group.examples.first
    reporter = Spec::Runner::Reporter.new(options)
    lambda {
      reporter.example_finished(example,::Spec::Example::ExamplePendingError.new)
    }.should_not raise_error
  end
end

