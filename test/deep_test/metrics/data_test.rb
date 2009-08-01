require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Metrics
    class DataTest < ::Test::Unit::TestCase
      test "measurements are summarized in report" do
        data = Data.new
        data.add Measurement.new("category a", 1, "bytes")
        data.add Measurement.new("category b", 2, "seconds")
        data.add Measurement.new("category a", 2, "bytes")
        data.add Measurement.new("category b", 3, "seconds")

        assert_equal <<-end_text, data.summary
Metrics Data
------------
category a: 1.5 avg / 3 total bytes
category b: 2.5 avg / 5 total seconds
        end_text
      end
    end
  end
end
