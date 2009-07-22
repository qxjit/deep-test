require 'rubygems'
gem 'rspec', '1.1.12'
require 'spec'
require File.dirname(__FILE__) + "/../lib/deep_test"

describe "failing" do
  it "fails" do
    false.should == true
  end
end
