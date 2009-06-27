require File.dirname(__FILE__) + "/../../spec_helper"

module DeepTest
  module Spec
    describe Runner do
      it_should_behave_like 'sandboxed rspec_options'

      it "should run each test using central_command" do
        central_command = SimpleTestCentralCommand.new
        runner = Runner.new(options, Options.new({}).to_command_line, central_command)

        describe("test") do
          it("passes1") {}
          it("passes2") {}
        end

        agent = ThreadAgent.new(central_command, 2)
        Timeout.timeout(5) do
          runner.process_work_units.should == true
        end
        agent.wait_until_done

        agent.work_done.should == 2
        options.reporter.number_of_examples.should == 2
        central_command.take_result.should be_nil
        options.reporter.examples_finished.should == ['passes1','passes2']
        options.reporter.should be_ended
      end

      it "should return failure when a spec fails" do
        central_command = SimpleTestCentralCommand.new
        runner = Runner.new(options, Options.new({}).to_command_line, central_command)

        describe("test") do
          it("passes") {}; 
          it("fails") {1.should == 2}; 
        end

        agent = ThreadAgent.new(central_command, 2)
        Timeout.timeout(5) do
          runner.process_work_units.should == false
        end
        agent.wait_until_done
      end

      it "should return success when there are pending examples" do
        central_command = SimpleTestCentralCommand.new
        runner = Runner.new(options, Options.new({}).to_command_line, central_command)

        describe("test") do
          it("pending") {pending {1.should == 2}}; 
        end

        agent = ThreadAgent.new(central_command, 1)
        Timeout.timeout(5) do
          runner.process_work_units.should == true
        end
        agent.wait_until_done
      end

      it "should return failure when a pending example passes" do
        central_command = SimpleTestCentralCommand.new
        runner = Runner.new(options, Options.new({}).to_command_line, central_command)

        describe("test") do
          it("pending") {pending {1.should == 1}}; 
        end

        agent = ThreadAgent.new(central_command, 1)
        Timeout.timeout(5) do
          runner.process_work_units.should == false
        end
        agent.wait_until_done
      end

      it "should return failure when a agent error occurs" do
        central_command = SimpleTestCentralCommand.new
        runner = Runner.new(options, Options.new({}).to_command_line, central_command)

        describe("test") do
          it("pending") {pending {1.should == 1}}; 
        end

        central_command.write_result Agent::Error.new("example", RuntimeError.new)
        capture_stdout do
          runner.process_work_units.should == false
        end

        options.reporter.number_of_errors.should == 1
      end

      it "should raise error if duplicate spec is found" do
        central_command = SimpleTestCentralCommand.new
        runner = Runner.new(options, Options.new({}).to_command_line, central_command)

        describe("test") do
          2.times {it("example") {}}; 
        end

        lambda {
          runner.process_work_units
        }.should raise_error
      end
    end
  end
end
