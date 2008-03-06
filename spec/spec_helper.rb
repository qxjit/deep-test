require File.dirname(__FILE__) + "/../lib/deep_test"
require File.dirname(__FILE__) + "/../test/fake_deadlock_error"
require File.dirname(__FILE__) + "/../test/simple_test_blackboard"
require File.dirname(__FILE__) + "/thread_worker"

describe "sandboxed rspec_options", :shared => true do
  attr_reader :options

  before(:each) do
    @original_rspec_options = $rspec_options
    @options = ::Spec::Runner::Options.new(StringIO.new, StringIO.new)
    @options.reporter = FakeReporter.new
    $rspec_options = @options
  end

  after(:each) do
    $rspec_options = @original_rspec_options
  end

  class FakeReporter
    attr_reader :number_of_examples, :examples_finished

    def initialize
      @examples_finished = []
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
      @error = error
    end

    def passed?
      @error == nil
    end
  end
end
