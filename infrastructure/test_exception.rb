module DeepTest
  class TestException < StandardError
    def ==(other)
      other.class == self.class && other.message == message
    end
  end
end
