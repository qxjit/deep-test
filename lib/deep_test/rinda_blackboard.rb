module DeepTest
  class RindaBlackboard
    def initialize(tuple_space = TupleSpaceFactory.tuple_space)
      @tuple_space = tuple_space
    end
    
    def take_result
      result = @tuple_space.take ["test_result", nil], 30
      result[1]
    end

    def take_test
      tuple = @tuple_space.take ["run_test", nil, nil], 30
      eval(tuple[1]).new(tuple[2])
    end

    def write_result(result)
      @tuple_space.write ["test_result", result]
    end

    def write_test(test_case)
      @tuple_space.write ["run_test", test_case.class.to_s, test_case.method_name]
    end
  end
end
