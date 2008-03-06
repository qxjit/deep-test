module Spec
  module Runner
    class Options
      def run_one_example(file, line_number)
        @examples = [SpecParser.new.spec_name_for(file, line_number)]
        ExampleGroupRunner.new(self).run
      end
    end
  end
end

