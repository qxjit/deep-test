require 'rubygems'
require 'test/unit'
require 'dust'

unit_tests do
  100.times do |i|
    test "dying #{i}" do
      exit! 0
    end
  end
end


