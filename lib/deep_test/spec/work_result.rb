module DeepTest
  module Spec
    class WorkResult
      attr_reader :identifier, :error, :output
      def initialize(identifier, error, output)
        @identifier, @error, @output = identifier, error, output
      end

      def ==(other)
        identifier == other.identifier && error == other.error 
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
