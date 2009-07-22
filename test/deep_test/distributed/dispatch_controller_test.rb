require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "dispatch invokes each receiver once" do
        receiver_1, receiver_2 = mock, mock

        controller = DispatchController.new(
          Options.new({:ui => "UI::Null"}), 
          [receiver_1, receiver_2]
        )

        receiver_1.expects(:a_method).with(:args)
        receiver_2.expects(:a_method).with(:args)

        controller.dispatch(:a_method, :args)
      end

      test "dispatch returns array of all results" do
        receiver_1, receiver_2 = mock, mock

        controller = DispatchController.new(
          Options.new({:ui => "UI::Null"}), 
          [receiver_1, receiver_2]
        )

        receiver_1.expects(:a_method).returns(:result_1)
        receiver_2.expects(:a_method).returns(:result_2)

        results = controller.dispatch(:a_method)
        assert_equal 2, results.size
        assert_equal [:result_1, :result_2].to_set, results.to_set
      end

      test "dispatch calls all receivers in parallel" do
        options = Options.new({:ui => "UI::Null"})
        waiter = Waiter.new(tracker = Tracker.new)

        Timeout.timeout(1) do
          DispatchController.new(options,[tracker, waiter]).
            dispatch(:tracked_method)
        end

        waiter = Waiter.new(tracker = Tracker.new)

        Timeout.timeout(1) do
          DispatchController.new(options,[waiter, tracker]).
            dispatch(:tracked_method)
        end
      end

      test "receiver is dropped when any exception occurs" do
        receiver = mock
        receiver.expects(:method_call).raises(Exception)

        controller = DispatchController.new(
          Options.new({:ui => "UI::Null"}),
          [receiver]
        )

        controller.dispatch(:method_call)
        assert_raises(NoDispatchReceiversError) {controller.dispatch(:another_call)}
      end

      test "error is printed with backtrace when it occurrs" do
        e = Exception.new("message")
        e.set_backtrace %w[file1:1 file2:2]
        receiver = mock
        receiver.expects(:method_call).raises(e)

        controller = DispatchController.new(
          Options.new({:ui => "UI::Null"}),
          [receiver]
        )

        controller.dispatch(:method_call)
        assert_equal <<-end_log, DeepTest.logger.logged_output
[DeepTest] Exception while dispatching method_call to #{receiver.inspect}:
[DeepTest] Exception: message
[DeepTest] file1:1
[DeepTest] file2:2
        end_log
      end

      test "dispatch calls notifies ui of start and stop of dispatch" do
        options = Options.new({:ui => "UI::Null"})
        controller = DispatchController.new(
          options, [stub_everything]
        )

        options.ui_instance.expects(:dispatch_starting).with(:method_name)
        options.ui_instance.expects(:dispatch_finished).with(:method_name)
        
        controller.dispatch(:method_name)
      end

      test "dispatch calls notifies ui dispatch end in case of an error" do
        options = Options.new({:ui => "UI::Null"})
        controller = DispatchController.new(
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
        options = Options.new({:ui => "UI::Null"})
        controller = DispatchController.new(
          options, []
        )

        assert_raises(NoDispatchReceiversError) do
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
  end
end
