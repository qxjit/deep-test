require 'rubygems'
require 'deep_test/server'
require 'deep_test/tuple_space_factory'
require 'spec'

class Runner
  def initialize
    @behaviours = []
    @tuple_space = DeepTest::TupleSpaceFactory.tuple_space

    @backtrace_tweaker = Spec::Runner::QuietBacktraceTweaker.new
    @formatters = [Spec::Runner::Formatter::ProgressBarFormatter.new($stdout)]
    @reporter = Spec::Runner::Reporter.new(@formatters, @backtrace_tweaker)
    @examples = []
  end

  def add_behaviour(behaviour)
    @behaviours << behaviour
    @examples.concat behaviour.examples
  end

  def run
    total = 0

    @reporter.start @examples.length

    @behaviours.each do |b|
      b.examples.each do |e|
        tuple = ['run_spec', e.from]
        @tuple_space.write tuple
        total += 1
      end
    end

    while total > 0
      tuple = @tuple_space.take ['spec_result', nil, nil, nil, nil]
      from = tuple[1]
      example = @examples.find {|e| e.from == from}
      @reporter.example_finished example, tuple[2], tuple[3], tuple[4]
      total -= 1
    end

    @reporter.end
    @reporter.dump
  end
end

module Spec
  module DSL
    class Example
      attr_reader :from
    end
  end
end

$behaviour_runner = Runner.new
require File.dirname(__FILE__) + '/../spec/example_spec'
$behaviour_runner.run
