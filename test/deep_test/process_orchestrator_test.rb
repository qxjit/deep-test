require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "shutdown calls done_with_work" do
      orchestrator = ProcessOrchestrator.new(nil, stub_everything, nil)
      server = mock
      server.expects(:done_with_work)

      orchestrator.shutdown(server)
    end
  end
end
