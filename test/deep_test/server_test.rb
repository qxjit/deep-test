require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "take_work returns result of push_work when it is available" do
      server = Server.new(Options.new({}))
      server.write_work :work
      assert_equal :work, server.take_work
    end

    test "take_work raises error when no work is currently available" do
      assert_raises(Server::NoWorkUnitsAvailableError) do
        Server.new(Options.new({})).take_work
      end
    end

    test "take_work raises error when there is no work left to" do
      server = Server.new(Options.new({}))
      server.done_with_work

      assert_raises(Server::NoWorkUnitsRemainingError) do
        server.take_work
      end
    end

    test "take_result returns result of push_result when it is available" do
      server = Server.new(Options.new({}))
      t = Thread.new {server.take_result}
      server.write_result :result
      assert_equal :result, t.value
    end

    test "take_result timeouts out after configurable number of seconds" do
      server = Server.new(
        Options.new(:timeout_in_seconds => 0.01)
      )
      Thread.new {sleep 0.1; server.write_result :too_late}
      assert_raises(Server::ResultOverdueError) {server.take_result}
    end

    test "write_work returns nil" do
      server = Server.new(Options.new({}))
      assert_equal nil, server.write_work(:a)
    end

    test "write_result returns nil" do
      server = Server.new(Options.new({}))
      assert_equal nil, server.write_result(:a)
    end

    test "start returns instance of server" do
      DRb.expects(:start_service)
      DRb.expects(:uri)
      DeepTest.logger.expects(:info)

      server = Server.start(Options.new({}))
      assert_kind_of Server, server
    end
  end
end
