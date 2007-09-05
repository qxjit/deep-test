require File.dirname(__FILE__) + "/../test_helper"
require "deep_test/loader" unless defined?(DeepTest::Loader)

unit_tests do
  test "no filters constant has empty filters" do
    assert_equal [], DeepTest::Loader::NO_FILTERS.filters
  end
end
