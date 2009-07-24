require 'rubygems'
require 'test/unit'
require 'dust'

unit_tests do
  10.times do |i|
    test "passing #{i}" do
      assert true
    end
  end
end

