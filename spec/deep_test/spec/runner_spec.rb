require File.dirname(__FILE__) + "/../../spec_helper"

module DeepTest
  module Spec
    describe Runner do
      it_should_behave_like 'sandboxed rspec_options'

      it "should run each test using blackboard" do
        blackboard = SimpleTestBlackboard.new
        runner = Runner.new(options, Options.new({}), blackboard)

        Class.new(::Spec::Example::ExampleGroup) do
          it("passes1") {}
          it("passes2") {}
        end

        worker = ThreadWorker.new(blackboard, 2)
        Timeout.timeout(5) do
          runner.process_work_units.should == true
        end
        worker.wait_until_done

        worker.work_done.should == 2
        options.reporter.number_of_examples.should == 2
        blackboard.take_result.should be_nil
        options.reporter.examples_finished.should == ['passes1','passes2']
        options.reporter.should be_ended
      end

      it "should return failure when a spec fails" do
        blackboard = SimpleTestBlackboard.new
        runner = Runner.new(options, Options.new({}), blackboard)

        Class.new(::Spec::Example::ExampleGroup) do
          it("passes") {}; 
          it("fails") {1.should == 2}; 
        end

        worker = ThreadWorker.new(blackboard, 2)
        Timeout.timeout(5) do
          runner.process_work_units.should == false
        end
        worker.wait_until_done
      end

      it "should return success when there are pending examples" do
        blackboard = SimpleTestBlackboard.new
        runner = Runner.new(options, Options.new({}), blackboard)

        Class.new(::Spec::Example::ExampleGroup) do
          it("pending") {pending {1.should == 2}}; 
        end

        worker = ThreadWorker.new(blackboard, 1)
        Timeout.timeout(5) do
          runner.process_work_units.should == true
        end
        worker.wait_until_done
      end

      it "should return failure when a pending example passes" do
        blackboard = SimpleTestBlackboard.new
        runner = Runner.new(options, Options.new({}), blackboard)

        Class.new(::Spec::Example::ExampleGroup) do
          it("pending") {pending {1.should == 1}}; 
        end

        worker = ThreadWorker.new(blackboard, 1)
        Timeout.timeout(5) do
          runner.process_work_units.should == false
        end
        worker.wait_until_done
      end

      it "should prints that was produced by specs" do
        blackboard = SimpleTestBlackboard.new
        runner = Runner.new(options, Options.new({}), blackboard)

        Class.new(::Spec::Example::ExampleGroup) do
          it("prints") {puts "hello"}; 
        end

        worker = ThreadWorker.new(blackboard, 1)
        class <<runner
          def print(string)
            output << string
          end

          def output
            @output ||= ""
          end
        end
        Timeout.timeout(5) do
          runner.process_work_units
        end
        worker.wait_until_done
        runner.output.should == "hello\n"
      end

    end
  end
end
