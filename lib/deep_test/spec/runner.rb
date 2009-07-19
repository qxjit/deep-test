module DeepTest
  module Spec
    class Runner < ::Spec::Runner::ExampleGroupRunner
      def initialize(options, deep_test_options)
        super(options)
        if ::Spec::VERSION::MAJOR == 1 &&
           ::Spec::VERSION::MINOR == 1 &&
           ::Spec::VERSION::TINY  >= 12
          @runner_options = options # added to make work with 1.1.12
        end
        @deep_test_options = DeepTest::Options.from_command_line(deep_test_options)
        DeepTest.init @deep_test_options
      end

      def main
        @main ||= Main.new @deep_test_options, @deep_test_options.new_deployment, self
      end

      def central_command
        # Can't create central_command as default argument to initialize
        # because Main hasn't been invoked at 
        # instantiation time
        @central_command ||= main.central_command
      end

      def load_files(files)
        main.load_files files
      end

      def run
        main.run
      end

      def process_work_units(central_command)
        prepare

        examples = (example_groups.map do |g|
          if ::Spec::VERSION::MAJOR == 1 &&
             ::Spec::VERSION::MINOR == 1 &&
             ::Spec::VERSION::TINY  >= 12
            g.send(:examples_to_run, @runner_options) # added @runner_options to make wiork with 1.1.12
          else
            g.send(:examples_to_run)
          end
        end).flatten
        examples_by_location = {}
        examples.each do |example|
          raise "duplicate example: #{example.identifier}" if examples_by_location[example.identifier]
          examples_by_location[example.identifier] = example
          central_command.write_work Spec::WorkUnit.new(example.identifier)
        end

        success = true

        missing_exmaples = ResultReader.new(central_command).read(examples_by_location) do |example, result|
          @options.reporter.example_finished(example, result.error)
          success &= result.success?
        end

        success &= missing_exmaples.empty?

        missing_exmaples.each do |identifier, example|
          @options.reporter.example_finished(example, WorkUnitNeverReceivedError.new)
        end

        success
      ensure
        finish
      end
    end
  end
end
