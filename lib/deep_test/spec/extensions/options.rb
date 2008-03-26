module Spec
  module Runner
    class Options
      def run_one_example(identifier)
        @examples = ["#{identifier.group_description} #{identifier.description}"]
        ExampleGroupRunner.new(self).run
      end
    end
  end
end

