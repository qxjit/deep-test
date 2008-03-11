module Spec
  module Example
    module ExampleGroupMethods
      PREPEND_BEFORE = instance_method(:prepend_before) unless defined?(PREPEND_BEFORE)
      APPEND_BEFORE = instance_method(:append_before) unless defined?(APPEND_BEFORE)
      PREPEND_AFTER = instance_method(:prepend_after) unless defined?(PREPEND_AFTER)
      APPEND_AFTER = instance_method(:append_after) unless defined?(APPEND_AFTER)

      def prepend_before(*args, &block)
        check_filter_args(args)
        PREPEND_BEFORE.bind(self).call(*args, &block)
      end

      def append_before(*args, &block)
        check_filter_args(args)
        APPEND_BEFORE.bind(self).call(*args, &block)
      end
      alias_method :before, :append_before

      def prepend_after(*args, &block)
        check_filter_args(args)
        PREPEND_AFTER.bind(self).call(*args, &block)
      end

      def append_after(*args, &block)
        check_filter_args(args)
        APPEND_AFTER.bind(self).call(*args, &block)
      end
      alias_method :after, :append_after

      def check_filter_args(args)
        raise BeforeAfterAllNotSupportedByDeepTestError if args.first == :all
      end

      class BeforeAfterAllNotSupportedByDeepTestError < StandardError; end
    end
  end
end
