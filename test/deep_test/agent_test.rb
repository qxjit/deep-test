require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "puts result on central_command" do
      central_command = FakeCentralCommand.new
      central_command.write_work Test::WorkUnit.new(TestFactory.passing_test)

      Agent.new(0, central_command,stub_everything).execute

      assert_kind_of ::Test::Unit::TestResult, central_command.take_result
    end

    test "puts passing and failing tests on central_command for each test" do
      central_command = FakeCentralCommand.new
      central_command.write_work Test::WorkUnit.new(TestFactory.passing_test)
      central_command.write_work Test::WorkUnit.new(TestFactory.failing_test)

      Agent.new(0, central_command, stub_everything).execute

      result_1 = central_command.take_result
      result_2 = central_command.take_result

      assert_equal true, (result_1.passed? || result_2.passed?)
      assert_equal false, (result_1.passed? && result_2.passed?)
    end

    test "notifies listener that it is starting" do
      central_command = FakeCentralCommand.new
      listener = stub_everything
      agent = Agent.new(0, central_command, listener)
      listener.expects(:starting).with(agent)
      agent.execute
    end

    test "notifies listener that it is about to do work" do
      central_command = FakeCentralCommand.new
      work_unit = Test::WorkUnit.new(TestFactory.passing_test)
      central_command.write_work work_unit
      listener = stub_everything
      agent = Agent.new(0, central_command, listener)
      listener.expects(:starting_work).with(agent, work_unit)
      agent.execute
    end

    test "notifies listener that it has done work" do
      central_command = FakeCentralCommand.new
      work_unit = mock(:run => :result)
      central_command.write_work work_unit
      listener = stub_everything
      agent = Agent.new(0, central_command, listener)
      listener.expects(:finished_work).with(agent, work_unit, :result)
      agent.execute
    end

    test "exception raised by work unit gives in Agent::Error" do
      central_command = FakeCentralCommand.new
      work_unit = mock
      work_unit.expects(:run).raises(exception = RuntimeError.new)
      central_command.write_work work_unit

      Agent.new(0, central_command, stub_everything).execute
      
      assert_equal Agent::Error.new(work_unit, exception),
                   central_command.take_result
    end

    test "Agent::Error can marshal itself even if it's contents are not marshallable" do
      o = Object.new
      o.extend DRb::DRbUndumped

      error = Agent::Error.new o, Exception.new("my error")
      error_through_marshalling = Marshal.load Marshal.dump(error)
      assert_equal Exception, error_through_marshalling.error.class
      assert_equal "my error", error_through_marshalling.error.message
      assert_equal "<< Undumpable >>", error_through_marshalling.work_unit
    end

    test "requests work until it finds some" do
      central_command = mock
      central_command.expects(:take_work).times(3).
        raises(CentralCommand::NoWorkUnitsAvailableError).
        returns(work_unit = mock(:run => nil)).
        returns(nil)

      central_command.expects(:write_result)

      Agent.new(0, central_command, stub_everything).execute
    end

    test "finishes running when no more work units are remaining" do
      central_command = mock
      central_command.expects(:take_work).raises(CentralCommand::NoWorkUnitsRemainingError)

      Agent.new(0, central_command, stub_everything).execute
    end

    test "finished running if a connection error is received" do
      central_command = mock
      central_command.expects(:take_work).raises(DRb::DRbConnError)

      Agent.new(0, central_command, stub_everything).execute
    end

    test "finished running if take work takes too long" do
      central_command = Object.new
      def central_command.take_work; loop {sleep 0.1} end

      Agent.new(0, central_command, stub_everything).execute
    end


    test "stops looking for work once it is stopped" do
      central_command = mock
      central_command.stubs(:take_work).raises(CentralCommand::NoWorkUnitsAvailableError)

      agent = Agent.new(0, central_command, stub_everything)
      t = Thread.new { agent.execute }
      Thread.pass
      agent.heartbeat_stopped
      t.join
    end

    test "number is available to indentify agent" do
      assert_equal 1, Agent.new(1, nil, nil).number
    end
    
    test "does not fork from rake" do
      assert !defined?($rakefile)
    end
  end
end
