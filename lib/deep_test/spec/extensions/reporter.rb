require 'spec/runner/reporter'
module Spec
  module Runner
    class Reporter
      def example_finished(example, error=nil)
        @examples << example
        
        if error.nil?
          example_passed(example)
        elsif Spec::Example::ExamplePendingError === error
          example_pending(example.class, example, error.message)
        else
          example_failed(example, error)
        end
      end

      def failure(example, error)
        backtrace_tweaker.tweak_backtrace(error)
        example_name = "#{example.class.description} #{example.description}"
        failure = Failure.new(example_name, error)
        @failures << failure
        formatters.each do |f|
          f.example_failed(example, @failures.length, failure)
        end
      end
      alias_method :example_failed, :failure
    end
  end
end
