module DeepTest
  module Spec
    class WorkUnit
      def initialize(identifier)
        @identifier = identifier
      end

      def run
        # Dup options here to avoid clobbering the reporter on someone
        # elses options reference (Such as ExampleGroupRunner)
        original_options = ::Spec::Runner.options
        ::Spec::Runner.use ::Spec::Runner.options.dup
        ::Spec::Runner.options.reporter = ResultReporter.new(@identifier)
        result = run_without_deadlock_protection
        result = run_without_deadlock_protection if result.failed_due_to_deadlock?
        result = result.deadlock_result if result.failed_due_to_deadlock?
        result
      ensure
        ::Spec::Runner.use original_options
      end

      def to_s
        "#{@identifier.group_description}: #{@identifier.description}"
      end

      protected

      def run_without_deadlock_protection
        output = capture_stdout do
          ::Spec::Runner.options.run_one_example(@identifier)
        end
        ::Spec::Runner.options.reporter.result(output)
      end

      class ResultReporter
        attr_reader :result

        def initialize(identifier)
          @identifier = identifier 
        end

        def add_example_group(example_group); end
        def dump; end
        def end; end
        def example_started(name); end

        def example_finished(example, error)
          @example, @error = example, error
        end

        def result(output)
          Spec::WorkResult.new(@identifier, @error, output)
        end

        def start(example); end
      end
    end
  end
end
