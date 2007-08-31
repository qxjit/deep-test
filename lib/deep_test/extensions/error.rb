module Test
  module Unit
    class Error
      def initialize_with_exception_wrapping(test_name, exception)
        wrap = Exception.new "#{exception.class}: #{exception.message}"
        wrap.set_backtrace exception.backtrace
        @test_name = test_name
        @exception = wrap
      end
      alias_method :initialize_without_exception_wrapping, :initialize
      alias_method :initialize, :initialize_with_exception_wrapping
    end
  end
end
