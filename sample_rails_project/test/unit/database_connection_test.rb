require File.dirname(__FILE__) + '/../test_helper'

unit_tests do
  test "not connected to normal test or development database under deep_test" do
    current_database = ActiveRecord::Base.connection.current_database
    if defined?(DeepTest)
      assert_not_equal "sample_rails_project_development", current_database
      assert_not_equal "sample_rails_project_test", current_database
    else
      assert_equal "sample_rails_project_test", current_database
    end
  end
end
