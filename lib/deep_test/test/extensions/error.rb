module Test
  module Unit
    class Error
      def exception
        return @exception.resolve if @exception.kind_of?(DeepTest::MarshallableException)
        @exception
      end

      def make_exception_marshallable
        return if @exception.kind_of?(DeepTest::MarshallableException)
        @exception = DeepTest::MarshallableException.new(@exception)
      end
    end
  end
end
