require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "dump_schema includes procedures" do
    listener = DeepTest::Database::MysqlSetupListener.new
    listener.expects(:system).with do |command|
      command =~ / -R /
    end
    listener.expects(:master_database_config).returns({})
    listener.expects(:dump_file_name).returns("")
    $?.expects(:success?).returns(true)
    listener.dump_schema
  end
end
