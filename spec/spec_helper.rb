require File.dirname(__FILE__) + "/../lib/deep_test"
require File.dirname(__FILE__) + "/../test/fake_deadlock_error"
require File.dirname(__FILE__) + "/../test/simple_test_central_command"
require File.dirname(__FILE__) + "/thread_agent"
require 'spec'

describe "sandboxed rspec_options", :shared => true do
  attr_reader :options

  before(:each) do
    @original_rspec_options = ::Spec::Runner.options
    @options = ::Spec::Runner::Options.new(StringIO.new, StringIO.new)
    @options.reporter = FakeReporter.new
    ::Spec::Runner.use @options
  end

  after(:each) do
    ::Spec::Runner.use @original_rspec_options
  end

  class FakeReporter
    attr_reader :number_of_examples, :examples_finished, :number_of_errors

    def initialize
      @examples_finished = []
      @number_of_errors = 0
    end

    def example_started(example) end
    def add_example_group(example_group) end

    def end
      @ended = true
    end

    def ended?
      @ended == true
    end

    def dump; end

    def start(number_of_examples) 
      @number_of_examples = number_of_examples
    end

    def example_finished(example, error)
      @examples_finished << example.description
      @number_of_errors += 1 if error
      @error = error
    end

    def passed?
      @error == nil
    end
  end
end
