require 'rubygems'
gem 'rspec', '1.1.12'
require 'spec'
require File.dirname(__FILE__) + "/../lib/deep_test"

describe "passing" do
  it "passes" do
    true.should == true
  end
end

