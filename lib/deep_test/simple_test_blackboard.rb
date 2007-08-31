module DeepTest
  class SimpleTestBlackboard
    def initialize
      @test_cases = []
      @test_results = []
    end

    def take_result
      @test_results.shift
    end

    def take_test
      @test_cases.shift
    end

    def write_result(result)
      @test_results.push result
    end

    def write_test(test_case)
      @test_cases.push test_case
    end
  end
end
