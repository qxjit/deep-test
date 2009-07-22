require 'rubygems'
gem 'rspec', '1.1.12'
require 'spec'

describe "failing" do
  it "fails" do
    false.should == true
  end
end
