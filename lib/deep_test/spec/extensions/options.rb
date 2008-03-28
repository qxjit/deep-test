module Spec
  module Runner
    class Options
      def run_one_example(identifier)
        example = identifier.locate(example_groups)
        SingleExampleRunner.new(self, example).run
      end

      class SingleExampleRunner < ExampleGroupRunner
        def initialize(options, example)
          super(options)
          @example = example
          example_group.extend ExampleGroupHelper
        end

        def example_group
          @example.class
        end

        def example_groups
          [example_group]
        end

        def run
          example_group.with_example_objects([@example]) do
            super
          end
        end

        module ExampleGroupHelper
          def with_example_objects(example_objects)
            original_example_objects = @example_objects
            @example_objects = example_objects
            yield
          ensure
            @example_objects = original_example_objects
          end
        end
      end
    end
  end
end

