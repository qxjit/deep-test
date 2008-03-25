require File.dirname(__FILE__) + '/../test_helper'

unit_tests do
  test "can create person" do
    person = Person.create! :name => "Bob"
    assert_equal "Bob", person.name 
  end

  test "person created in db:test:prepare is available" do
    assert_not_nil Person.find_by_name("Created In db:test:prepare"),
                   "Person created in db:test:prepare not in #{ActiveRecord::Base.connection.current_database} database"
  end
end
