require 'spec/runner/reporter'
module Spec
  module Runner
    class Reporter
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
