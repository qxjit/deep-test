require 'rubygems'
gem 'rspec', '1.1.12'
require 'spec'

describe "passing" do
  it "passes" do
    true.should == true
  end
end

