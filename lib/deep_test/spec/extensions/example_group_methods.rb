module Spec
  module Example
    module ExampleGroupMethods
      class << self
        def assign_instance_method_to_constant(proposed_constant)
          method_sym = proposed_constant.to_s.downcase

          unless const_defined?(proposed_constant)
            const_set(proposed_constant, instance_method(method_sym))
          end
        end
        
        private :assign_instance_method_to_constant
      end
      
      class BeforeAfterAllNotSupportedByDeepTestError < StandardError; end

      assign_instance_method_to_constant :PREPEND_BEFORE
      assign_instance_method_to_constant :APPEND_BEFORE
      assign_instance_method_to_constant :PREPEND_AFTER
      assign_instance_method_to_constant :APPEND_AFTER

      def prepend_before(*args, &block)
        check_filter_args(args)
        call_regular_instance_method :prepend_before, *args, &block
      end

      def append_before(*args, &block)
        check_filter_args(args)
        call_regular_instance_method :append_before, *args, &block
      end
      
      alias_method :before, :append_before

      def prepend_after(*args, &block)
        check_filter_args(args)
        call_regular_instance_method :prepend_after, *args, &block
      end

      def append_after(*args, &block)
        check_filter_args(args)
        call_regular_instance_method :append_after, *args, &block
      end
      
      alias_method :after, :append_after

    private
    
      def check_filter_args(args)
        raise BeforeAfterAllNotSupportedByDeepTestError if args.first == :all
      end
    
      def call_regular_instance_method(sym, *args, &block)
        ExampleGroupMethods.const_get(sym.to_s.upcase).bind(self).call(*args, &block)
      end
    end
  end
end
