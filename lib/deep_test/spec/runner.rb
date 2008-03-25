module DeepTest
  module Spec
    class Runner < ::Spec::Runner::ExampleGroupRunner
      def initialize(options, deep_test_options, blackboard = nil)
        super(options)
        @deep_test_options = DeepTest::Options.from_command_line(deep_test_options)
        @blackboard = blackboard
        @workers = @deep_test_options.new_workers
      end

      def blackboard
        # Can't create blackboard as default argument to initialize
        # because ProcessOrchestrator hasn't been invoked at 
        # instantiation time
        @blackboard ||= Server.connect(@deep_test_options)
      end

      def load_files(files)
        @workers.load_files files
      end

      def run
        ProcessOrchestrator.run(@deep_test_options, @workers, self)
      end

      def process_work_units
        prepare

        examples = example_groups.map {|g| g.send(:examples_to_run)}.flatten
        examples_by_location = {}
        examples.each do |example|
          file, line, *rest = example.implementation_backtrace.first.split(/:/)
          examples_by_location["#{file}:#{line}"] = example
          blackboard.write_work Spec::WorkUnit.new(file, line.to_i)
        end

        success = true
        until examples_by_location.empty?
          Thread.pass
          result = blackboard.take_result
          next unless result
          print result.output if result.output
          example = examples_by_location.delete("#{result.file}:#{result.line}")
          @options.reporter.example_finished(example, result.error)
          success &= result.success?
        end

        success
      ensure
        finish
      end
    end
  end
end
