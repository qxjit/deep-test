require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Metrics
    class MeasurementTest < ::Test::Unit::TestCase
      test "of_time_taken should measure time an operation takes" do
        measurement = Measurement.of_time_taken("category") do
          sleep 0.5
        end

        assert_equal "category", measurement.category
        assert_in_delta 0.5, measurement.value, 0.1
        assert_equal "seconds", measurement.units
      end
    end
  end
end

