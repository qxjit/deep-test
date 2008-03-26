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
    
      DeepTestAllBlockWarning = 
        "Warning: DeepTest will run before(:all) and after(:all) blocks for *every* test that is run.  To remove this warning either convert all before/after blocks to each blocks or set $show_deep_test_all_block_warning to false"
      
      $show_deep_test_all_block_warning = true

      def check_filter_args(args)
        if args.first == :all && $show_deep_test_all_block_warning
          $show_deep_test_all_block_warning = false
          $stderr.puts DeepTestAllBlockWarning 
        end
      end
    
      def call_regular_instance_method(sym, *args, &block)
        ExampleGroupMethods.const_get(sym.to_s.upcase).bind(self).call(*args, &block)
      end
    end
  end
end
