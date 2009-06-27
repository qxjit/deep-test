require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "take_work returns result of push_work when it is available" do
      central_command = CentralCommand.new(Options.new({}))
      central_command.write_work :work
      assert_equal :work, central_command.take_work
    end

    test "take_work raises error when no work is currently available" do
      assert_raises(CentralCommand::NoWorkUnitsAvailableError) do
        CentralCommand.new(Options.new({})).take_work
      end
    end

    test "take_work raises error when there is no work left to" do
      central_command = CentralCommand.new(Options.new({}))
      central_command.done_with_work

      assert_raises(CentralCommand::NoWorkUnitsRemainingError) do
        central_command.take_work
      end
    end

    test "take_result returns result of push_result when it is available" do
      central_command = CentralCommand.new(Options.new({}))
      t = Thread.new {central_command.take_result}
      central_command.write_result :result
      assert_equal :result, t.value
    end

    test "take_result timeouts out after configurable number of seconds" do
      central_command = CentralCommand.new(
        Options.new(:timeout_in_seconds => 0.01)
      )
      Thread.new {sleep 0.1; central_command.write_result :too_late}
      assert_raises(CentralCommand::ResultOverdueError) {central_command.take_result}
    end

    test "write_work returns nil" do
      central_command = CentralCommand.new(Options.new({}))
      assert_equal nil, central_command.write_work(:a)
    end

    test "write_result returns nil" do
      central_command = CentralCommand.new(Options.new({}))
      assert_equal nil, central_command.write_result(:a)
    end

    test "start returns instance of central_command" do
      DRb.expects(:start_service)
      DRb.expects(:uri)

      central_command = CentralCommand.start(Options.new({}))
      assert_kind_of CentralCommand, central_command
    end
  end
end
