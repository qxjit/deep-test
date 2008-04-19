require File.dirname(__FILE__) + "/../../spec_helper"

describe DeepTest::Spec::WorkResult do
  it "should make errors marshallable" do
    result = DeepTest::Spec::WorkResult.new("id", Exception.new, nil)
    result.instance_variable_get(:@error).should be_instance_of(DeepTest::MarshallableExceptionWrapper)
    result.error.should be_instance_of(Exception)
  end

  it "should preserve nil errors" do
    result = DeepTest::Spec::WorkResult.new("id", nil, nil)
    result.error.should be_nil
  end
end
