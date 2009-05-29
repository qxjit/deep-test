require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Test
    unit_tests do
      test "no filters constant has empty filters" do
        assert_equal [], Runner::NO_FILTERS.filters
      end
    end
  end
end
