module Test
  module Unit
    class Error
      def resolve_marshallable_exception
        @exception = @exception.resolve if @exception.kind_of?(DeepTest::MarshallableExceptionWrapper)
      end

      def make_exception_marshallable
        return if @exception.kind_of?(DeepTest::MarshallableExceptionWrapper)
        @exception = DeepTest::MarshallableExceptionWrapper.new(@exception)
      end
    end
  end
end
