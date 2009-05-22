module DeepTest
  module Distributed
    class DispatchController
      def initialize(options, receivers)
        @options = options
        @receivers = receivers
      end

      def dispatch(method_name, *args)
        dispatch_with_options(method_name, {}, *args)
      end

      def dispatch_with_options(method_name, options, *args)
        raise NoDispatchReceiversError if @receivers.empty?

        @options.ui_instance.dispatch_starting(method_name)

        threads = @receivers.map do |r|
          Thread.new do
            Thread.current[:receiver] = r
            Timeout.timeout(@options.timeout_in_seconds) do
              r.send method_name, *args
            end
          end
        end

        results = []
        threads.each do |t|
          begin
            results << t.value
          rescue Timeout::Error
            @receivers.delete t[:receiver]
            DeepTest.logger.error "Timeout dispatching #{method_name} to #{description t[:receiver]}"
          rescue DRb::DRbConnError
            @receivers.delete t[:receiver]
            unless options[:ignore_connection_error]
              DeepTest.logger.error "Connection Refused dispatching #{method_name} to #{description t[:receiver]}"
            end
          rescue Exception => e
            @receivers.delete t[:receiver]
            DeepTest.logger.error "Exception while dispatching #{method_name} to #{description t[:receiver]} #{e.message}"
          end
        end

        results
      ensure
        @options.ui_instance.dispatch_finished(method_name)
      end

      def description(receiver)
        receiver.__drburi rescue receiver.inspect
      end

    end

    class NoDispatchReceiversError < StandardError; end
  end
end
