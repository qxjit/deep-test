module Telegraph
  class AckSequence
    def initialize
      @value = 0
    end

    def next
      Thread.exclusive do
        @value += 1
      end
    end
  end
end

