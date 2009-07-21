require File.dirname(__FILE__) + "/../../spec_helper"

module DeepTest
  module Spec
    describe Runner do
      it_should_behave_like 'sandboxed rspec_options'

      it "should run each test using central_command" do
        deep_test_options = Options.new({})
        central_command = TestCentralCommand.start deep_test_options
        runner = Runner.new(options, deep_test_options.to_command_line)

        describe("test") do
          it("passes1") {}
          it("passes2") {}
        end

        agent = ThreadAgent.new deep_test_options
        Timeout.timeout(5) do
          runner.process_work_units(central_command).should == true
        end
        central_command.done_with_work
        agent.wait_until_done

        agent.work_done.should == 2
        options.reporter.number_of_examples.should == 2
        central_command.remaining_result_count.should == 0
        options.reporter.examples_finished.should == ['passes1','passes2']
        options.reporter.should be_ended
      end

      it "should return failure when a spec fails" do
        deep_test_options = Options.new({})
        central_command = TestCentralCommand.start deep_test_options
        runner = Runner.new(options, deep_test_options.to_command_line)

        describe("test") do
          it("passes") {}; 
          it("fails") {1.should == 2}; 
        end

        agent = ThreadAgent.new(deep_test_options)
        Timeout.timeout(5) do
          runner.process_work_units(central_command).should == false
        end
        central_command.done_with_work
        agent.wait_until_done
      end

      it "should return success when there are pending examples" do
        deep_test_options = Options.new({})
        central_command = TestCentralCommand.start deep_test_options
        runner = Runner.new(options, deep_test_options.to_command_line)

        describe("test") do
          it("pending") {pending {1.should == 2}}; 
        end

        agent = ThreadAgent.new deep_test_options
        Timeout.timeout(5) do
          runner.process_work_units(central_command).should == true
        end
        central_command.done_with_work
        agent.wait_until_done
      end

      it "should return failure when a pending example passes" do
        deep_test_options = Options.new({})
        central_command = TestCentralCommand.start deep_test_options
        runner = Runner.new(options, deep_test_options.to_command_line)

        describe("test") do
          it("pending") {pending {1.should == 1}}; 
        end

        agent = ThreadAgent.new deep_test_options
        Timeout.timeout(5) do
          runner.process_work_units(central_command).should == false
        end
        central_command.done_with_work
        agent.wait_until_done
      end

      it "should return failure when a agent error occurs" do
        deep_test_options = Options.new({})
        central_command = TestCentralCommand.start deep_test_options
        runner = Runner.new(options, deep_test_options.to_command_line)

        describe("test") do
          it("pending") {pending {1.should == 1}}; 
        end

        central_command.write_result Agent::Error.new("example", RuntimeError.new)
        capture_stdout do
          runner.process_work_units(central_command).should == false
        end

        options.reporter.number_of_errors.should == 1
      end

      it "should raise error if duplicate spec is found" do
        deep_test_options = Options.new({})
        central_command = TestCentralCommand.start deep_test_options
        runner = Runner.new(options, deep_test_options.to_command_line)

        describe("test") do
          2.times {it("example") {}}; 
        end

        lambda {
          runner.process_work_units(central_command)
        }.should raise_error
      end
    end
  end
end
