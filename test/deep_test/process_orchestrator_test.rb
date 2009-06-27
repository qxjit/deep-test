require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "shutdown calls done_with_work" do
      orchestrator = ProcessOrchestrator.new(nil, stub_everything, nil)
      central_command = mock
      central_command.expects(:done_with_work)

      orchestrator.shutdown(central_command)
    end
  end
end
