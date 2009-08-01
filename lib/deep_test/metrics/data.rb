module DeepTest
  module Metrics
    class Data
      def initialize
        @measurements_by_category = {}
      end

      def add(measurement)
        categories = @measurements_by_category[measurement.category] ||= []
        categories << measurement
      end

      def summary
        summary = []
        summary << "Metrics Data\n"
        summary << "------------\n"

        @measurements_by_category.keys.sort.map do |category|
          measurements = @measurements_by_category[category]
          units = measurements.first.units
          summary << "#{category}: #{Measurement.average(measurements)} avg / #{Measurement.total(measurements)} total #{units}\n"
        end

        summary.join
      end

      def save(file)
        File.open(file, "w") do |f|
          f << summary
        end
      end
    end
  end
end
