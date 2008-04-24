require File.dirname(__FILE__) + "/../test_helper"

unit_tests do
  test "shutdown calls done_with_work" do
    orchestrator = DeepTest::ProcessOrchestrator.new(nil, stub_everything, nil)
    server = mock
    server.expects(:done_with_work)

    orchestrator.shutdown(server)
  end
end
