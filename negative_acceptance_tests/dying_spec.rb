require 'rubygems'
gem 'rspec', '1.1.12'
require 'spec'

describe "dying" do
  100.times do |i|
    it "#{i}" do
      exit! 0
    end
  end
end


