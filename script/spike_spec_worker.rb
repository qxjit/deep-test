require 'rubygems'
require 'deep_test/server'
require 'deep_test/tuple_space_factory'

module DeepTest
  class SpecWorker
    def initialize
      @tuple_space = TupleSpaceFactory.tuple_space
    end
    
    def run
      loop do
        tuple = @tuple_space.take ["run_test", nil, nil], 30
        p tuple
      end
    end
  end
end

if __FILE__ == $0
  DeepTest::SpecWorker.new.run
end