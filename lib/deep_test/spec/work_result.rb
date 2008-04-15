module DeepTest
  module Spec
    class WorkResult
      attr_reader :identifier, :output

      def initialize(identifier, error, output)
        @identifier, @output = identifier, output
        @error = MarshallableException.new error if error
      end

      def error
        @error.resolve if @error
      end

      def ==(other)
        identifier == other.identifier && 
            @error == other.instance_variable_get(:@error) 
      end

      def failed_due_to_deadlock?
        DeadlockDetector.due_to_deadlock?(@error)
      end

      def success?
        error.nil? || ::Spec::Example::ExamplePendingError === error
      end

      def deadlock_result
        WorkResult.new(identifier, nil, '-deadlock-')
      end
    end
  end
end
