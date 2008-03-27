require File.dirname(__FILE__) + "/../../../spec_helper"

module Spec
  module Example
    # NoMethodError: undefined method `subclass' if constant is used below
    # instead of string
    describe "ExampleGroupMethods" do
      before(:each) do
        $show_deep_test_all_block_warning = true
      end

      it_should_behave_like "sandboxed rspec_options"
      
      [:append_before, :before, :after, :prepend_before, :append_after, :prepend_after].each do |rspec_method|
        it "should print warning on first call to #{rspec_method}(:all)" do
          out = capture_stderr do
            describe("test") do
              send(rspec_method, :all) {}
              send(rspec_method, :all) {}
            end
          end

          out.should == ExampleGroupMethods::DeepTestAllBlockWarning + "\n"
        end

        it "should not print warning if global setting is turned off" do
          $show_deep_test_all_block_warning = false
          
          out = capture_stderr do
            describe("test") do
              send(rspec_method, :all) {}
            end
          end

          out.should == ""
        end
        
        it "should not raise error on #{rspec_method}(:each)" do
          lambda {
            describe("test") do
              send(rspec_method, :each) {}
            end
          }.should_not raise_error
        end
      end
    end
  end
end
