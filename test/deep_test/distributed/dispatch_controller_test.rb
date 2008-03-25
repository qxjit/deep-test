require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "dispatch invokes each receiver once" do
    receiver_1, receiver_2 = mock, mock

    controller = DeepTest::Distributed::DispatchController.new(
      DeepTest::Options.new({:ui => "DeepTest::UI::Null"}), 
      [receiver_1, receiver_2]
    )

    receiver_1.expects(:a_method).with(:args)
    receiver_2.expects(:a_method).with(:args)

    controller.dispatch(:a_method, :args)
  end

  test "dispatch returns array of all results" do
    receiver_1, receiver_2 = mock, mock

    controller = DeepTest::Distributed::DispatchController.new(
      DeepTest::Options.new({:ui => "DeepTest::UI::Null"}), 
      [receiver_1, receiver_2]
    )

    receiver_1.expects(:a_method).returns(:result_1)
    receiver_2.expects(:a_method).returns(:result_2)

    results = controller.dispatch(:a_method)
    assert_equal 2, results.size
    assert_equal [:result_1, :result_2].to_set, results.to_set
  end

  test "dispatch calls all receivers in parallel" do
    options = DeepTest::Options.new({:ui => "DeepTest::UI::Null"})
    waiter = Waiter.new(tracker = Tracker.new)

    Timeout.timeout(1) do
      DeepTest::Distributed::DispatchController.new(options,[tracker, waiter]).
        dispatch(:tracked_method)
    end

    waiter = Waiter.new(tracker = Tracker.new)

    Timeout.timeout(1) do
      DeepTest::Distributed::DispatchController.new(options,[waiter, tracker]).
        dispatch(:tracked_method)
    end
  end

  test "dispatch omits results that are taking too long" do
    receiver = Object.new
    def receiver.__drburi; ""; end
    def receiver.sleep_100_millis
      sleep 0.1
    end

    controller = DeepTest::Distributed::DispatchController.new(
      DeepTest::Options.new({:ui => "DeepTest::UI::Null", :timeout_in_seconds => 0.05}),
      [receiver]
    )

    DeepTest.logger.expects(:error)

    assert_equal [], controller.dispatch(:sleep_100_millis)
  end

  test "after timeout, no further calls are sent to that receiver" do
    receiver_1, receiver_2 = mock(:__drburi => ""), mock
    receiver_1.expects(:method_call_1).raises(Timeout::Error)
    receiver_1.expects(:method_call_2).never

    receiver_2.expects(:method_call_1)
    receiver_2.expects(:method_call_2)

    controller = DeepTest::Distributed::DispatchController.new(
      DeepTest::Options.new({:ui => "DeepTest::UI::Null", :timeout_in_seconds => 0.05}),
      [receiver_1, receiver_2]
    )

    DeepTest.logger.expects(:error)
    
    controller.dispatch(:method_call_1)
    controller.dispatch(:method_call_2)
  end

  test "receiver is dropped when connection is refused" do
    receiver_1, receiver_2 = mock(:__drburi => ""), mock
    receiver_1.expects(:method_call_1).raises(DRb::DRbConnError)
    receiver_1.expects(:method_call_2).never

    receiver_2.expects(:method_call_1).returns(:value)
    receiver_2.expects(:method_call_2)

    controller = DeepTest::Distributed::DispatchController.new(
      DeepTest::Options.new({:ui => "DeepTest::UI::Null", :timeout_in_seconds => 0.05}),
      [receiver_1, receiver_2]
    )

    DeepTest.logger.expects(:error)
    
    assert_equal [:value], controller.dispatch(:method_call_1)

    controller.dispatch(:method_call_2)
  end

  test "dispatch calls notifies ui of start and stop of dispatch" do
    options = DeepTest::Options.new({:ui => "DeepTest::UI::Null"})
    controller = DeepTest::Distributed::DispatchController.new(
      options, [stub_everything]
    )

    options.ui_instance.expects(:dispatch_starting).with(:method_name)
    options.ui_instance.expects(:dispatch_finished).with(:method_name)
    
    controller.dispatch(:method_name)
  end

  test "dispatch calls notifies ui dispatch end in case of an error" do
    options = DeepTest::Options.new({:ui => "DeepTest::UI::Null"})
    controller = DeepTest::Distributed::DispatchController.new(
      options, [receiver = mock]
    )
    receiver.expects(:method_name).raises("An Error")

    options.ui_instance.expects(:dispatch_starting).with(:method_name)
    options.ui_instance.expects(:dispatch_finished).with(:method_name)
    
    begin
      controller.dispatch(:method_name)
    rescue RuntimeError => e
      raise unless e.message == "An Error"
    end
  end

  test "error is raised if dispatch to no receivers in attempted" do
    options = DeepTest::Options.new({:ui => "DeepTest::UI::Null"})
    controller = DeepTest::Distributed::DispatchController.new(
      options, []
    )

    assert_raises(DeepTest::Distributed::NoDispatchReceiversError) do
      controller.dispatch(:any_method)
    end
  end

  class Tracker
    def initialize
      @mutex = Mutex.new
      @condvar = ConditionVariable.new
    end

    def tracked_method 
      @mutex.synchronize do
        @tracked_method_called = true
        @condvar.broadcast
      end
    end

    def wait_for_tracked_method
      @mutex.synchronize do
        loop do
          return if @tracked_method_called
          @condvar.wait(@mutex)
        end
      end
    end
  end

  class Waiter
    def initialize(tracker)
      @tracker = tracker
    end

    def tracked_method
      @tracker.wait_for_tracked_method
    end
  end
end
