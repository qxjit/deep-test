module Test
  module Unit
    class Error
      def exception
        return @exception.resolve if @exception.kind_of?(DeepTest::MarshallableExceptionWrapper)
        @exception
      end

      def make_exception_marshallable
        return if @exception.kind_of?(DeepTest::MarshallableExceptionWrapper)
        @exception = DeepTest::MarshallableExceptionWrapper.new(@exception)
      end
    end
  end
end
