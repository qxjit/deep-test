module DeepTest
  class RindaBlackboard
    def initialize
      require "rinda/ring"
      DRb.start_service
      ring_server = Rinda::RingFinger.primary
      ts = ring_server.read([:name, :TupleSpace, nil, nil])[2]
      @tuple_space = Rinda::TupleSpaceProxy.new ts
    end

    def take_result
      result = @tuple_space.take ["test_result", nil], 3
      result[1]
    end

    def take_test
      tuple = @tuple_space.take(["run_test", nil, nil])
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
