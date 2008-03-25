module Spec
  module Runner
    class Options
      def run_one_example(file, line_number)
        @examples = [find_example(file, line_number)]
        ExampleGroupRunner.new(self).run
      end

      # Faster than SpecParser.new.spec_name_for, and doesn't get slower as
      # backtraces get longer
      #
      def find_example(file, line_number)
        desired_backtrace = /^#{file}:#{line_number}/
        example_groups.each do |example_group|
          example_group.examples.each do |example|
            if example.implementation_backtrace.first =~ desired_backtrace    
              return "#{example.class.description} #{example.description}"
            end
          end
        end

        raise "No example found for #{file}:#{line_number}"
      end
    end
  end
end

