module DeepTest
  module Spec
    class WorkResult
      attr_reader :file, :line, :example_description, :error, :output
      def initialize(file, line, example_description, error, output)
        @file, @line, @example_description, @error, @output = 
         file,  line,  example_description,  error,  output
      end

      def ==(other)
                       file == other.file &&
                       line == other.line &&
        example_description == other.example_description &&
                      error == other.error 
      end

      def failed_due_to_deadlock?
        DeadlockDetector.due_to_deadlock?(@error)
      end

      def success?
        error.nil? || ::Spec::Example::ExamplePendingError === error
      end

      def deadlock_result
        WorkResult.new(file, line, example_description, nil, '-deadlock-')
      end
    end
  end
end
