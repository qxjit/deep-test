module DeepTest
  class RindaBlackboard
    def initialize(options, tuple_space = TupleSpaceFactory.tuple_space(options))
      @options = options
      @tuple_space = tuple_space
    end
    
    def take_result
      result = @tuple_space.take ["test_result", nil], @options.timeout_in_seconds
      result[1]
    end

    def take_work
      tuple = @tuple_space.take ["deep_work", nil], @options.timeout_in_seconds
      tuple[1]
    end

    def write_result(result)
      @tuple_space.write ["test_result", result]
    end

    def write_work(work_unit)
      @tuple_space.write ["deep_work", work_unit]
    end
  end
end
