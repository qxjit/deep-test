require File.dirname(__FILE__) + "/../test_helper"

unit_tests do
  test "forwards methods defined in NullWorkerListener to all listeners" do
    listener_1, listener_2 = mock, mock
    list = DeepTest::ListenerList.new([listener_1, listener_2])
    listener_1.expects(:starting).with(:worker)
    listener_2.expects(:starting).with(:worker)
    listener_1.expects(:starting_work).with(:worker, :work)
    listener_2.expects(:starting_work).with(:worker, :work)
    list.starting(:worker)
    list.starting_work(:worker, :work)
  end

  test "doesn't forward methods not defined in NullWorkerListener" do
    listener = mock
    listener.expects(:to_s).never
    DeepTest::ListenerList.new([listener]).to_s
  end
end
