module DeepTest
  class Demon
  end

  class ProcDemon < Demon
    def initialize(block)
      @block = block
    end

    def execute
      @block.call
    end
  end
end
