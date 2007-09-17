require 'rubygems'
require 'deep_test/server'
require 'deep_test/tuple_space_factory'
require 'spec'

class Runner
  def initialize
    @behaviours = []
  end

  def add_behaviour(behaviour)
    @behaviours << behaviour
  end

  def run(from, reporter, dry_run, timeout)
    b = @behaviours.find {|b| b.has?(from)}
    b.run_one_example(from, reporter, dry_run, timeout)
  end
end

class Reporter
  attr_reader :result

  def example_started(name)
  end
  
  def example_finished(name, error=nil, failure_location=nil, not_implemented = false)
    @result = [name.from, error, failure_location, not_implemented]
  end
end

$behaviour_runner = Runner.new

module Spec
  module DSL
    class Behaviour
      def has?(from)
        examples.any? {|e| e.from == from}
      end

      def run_one_example(from, reporter, dry_run=false, timeout=nil)
        prepare_execution_context_class
        example = examples.find {|e| e.from == from}
        example_execution_context = execution_context(example)
        befores = before_each_proc(behaviour_type) {|e| raise e}
        afters = after_each_proc(behaviour_type)
        example.run(reporter, befores, afters, dry_run, example_execution_context, timeout)
      end
    end
  end
end

module Spec
  module DSL
    class Example
      attr_reader :from
    end
  end
end

require File.dirname(__FILE__) + '/../spec/example_spec'

module DeepTest
  class SpecWorker
    def initialize
      @tuple_space = TupleSpaceFactory.tuple_space
    end
    
    def run
      loop do
        tuple = @tuple_space.take ["run_spec", nil], 30
        example_from = tuple[1]
        r = Reporter.new
        $behaviour_runner.run(example_from, r, false, 30)
        tuple = ["spec_result"].concat(r.result)
        puts "writing #{tuple.inspect}"
        @tuple_space.write tuple
      end
    end
  end
end

if __FILE__ == $0
  DeepTest::SpecWorker.new.run
end
