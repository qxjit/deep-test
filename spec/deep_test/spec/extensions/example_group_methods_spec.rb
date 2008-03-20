require File.dirname(__FILE__) + "/../../../spec_helper"

module Spec
  module Example
    describe ExampleGroupMethods do
      before :each do
        @error_class = ExampleGroupMethods::BeforeAfterAllNotSupportedByDeepTestError
      end
      
      it_should_behave_like "sandboxed rspec_options"
      
      [:append_before, :before, :after, :prepend_before, :append_after, :prepend_after].each do |rspec_method|
        it "should raise a BeforeAfterAllNotSupportedByDeepTestError on #{rspec_method}(:all)" do
          lambda {
            Class.new(Spec::Example::ExampleGroup) do
              self.send(rspec_method, :all) {}
            end
          }.should raise_error(@error_class)
        end
        
        it "should not raise error on #{rspec_method}(:each)" do
          lambda {
            Class.new(Spec::Example::ExampleGroup) do
              self.send(rspec_method, :each) {}
            end
          }.should_not raise_error
        end
      end
    end
  end
end
