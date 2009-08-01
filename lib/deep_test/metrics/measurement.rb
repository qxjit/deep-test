module DeepTest
  module Metrics
    class Measurement
      attr_reader :category, :value, :units

      def initialize(category, value, units)
        @category = category
        @value = value
        @units = units
      end

      def self.average(measurements)
        total(measurements).to_f / measurements.size
      end

      def self.total(measurements)
        measurements.inject(0) { |sum, m| sum + m.value }
      end

      def self.of_time_taken(category)
        start = Time.now
        yield
        Measurement.new category, Time.now - start, "seconds"
      end

      def self.send_home(category, wire, options)
        result = nil
        measurement = of_time_taken(category) { result = yield }
        if options.gathering_metrics?
          begin
            wire.send_message measurement
          rescue Telegraph::LineDead
          end
        end
        result
      end
    end
  end
end
