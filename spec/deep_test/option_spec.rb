require File.dirname(__FILE__) + "/../spec_helper"

module DeepTest
  describe Option do
    it "should have hash conversion" do
      option = Option.new(:name, Option::Hash, {})
      string = option.to_command_line({:a => "1", :b => "a"})
      string.should be_instance_of(String)
      option.from_command_line(string).should == {:a => "1", :b => "a"}
    end

    it "should support booleans in hash" do
      option = Option.new(:name, Option::Hash, {})
      string = option.to_command_line({:a => true})
      string.should be_instance_of(String)
      option.from_command_line(string).should == {:a => true}
    end

    it "should handle hash values with spaces" do
      option = Option.new(:name, Option::Hash, {})

      string = option.to_command_line(
        {:a => "has a space", :b => "has more spaces"}
      )

      string.should be_instance_of(String)

      option.from_command_line(string).should == 
        {:a => "has a space", :b => "has more spaces"}
    end
  end
end

