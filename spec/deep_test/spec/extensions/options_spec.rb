require File.dirname(__FILE__) + "/../../../spec_helper"

describe Spec::Runner::Options do
  it_should_behave_like "sandboxed rspec_options"

  it "should be able to run a single passing example" do
    line = nil
    example_group = Class.new(Spec::Example::ExampleGroup) do
      it("passes") {1.should == 1}; line = __LINE__
      it("fails") {1.should == 2}; 
    end
    options.run_one_example(__FILE__, line)
    options.reporter.passed?.should == true
  end 

  it "should be able to run a single failing example" do
    line = nil
    example_group = Class.new(Spec::Example::ExampleGroup) do
      it("passes") {1.should == 1}; 
      it("fails") {1.should == 2}; line = __LINE__
    end
    options.run_one_example(__FILE__, line)
    options.reporter.passed?.should == false
  end 
end
