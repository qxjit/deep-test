module DeepTest
  module Distributed
    class ThroughputStatistics
      attr_reader :test_count, :start_time, :end_time

      def initialize(test_count, start_time, end_time)
        @test_count, @start_time, @end_time = test_count, start_time, end_time
      end

      def timespan_in_seconds
        @end_time.to_f - @start_time.to_f
      end

      def tests_per_second
        @test_count / timespan_in_seconds
      end

      def summary
        <<-end_summary
#{test_count} tests run in #{timespan_in_seconds} seconds
(#{tests_per_second} tests / second)
        end_summary
      end
    end
  end
end
