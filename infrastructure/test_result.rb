module DeepTest
  class TestResult
    include CentralCommand::Result
    attr_reader :value

    def initialize(value)
      @value == value
    end

    def ==(other)
      value == other.value
    end
  end
end

