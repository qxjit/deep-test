module DeepTest
  module Distributed
    class ThroughputRunner
      def initialize(options, test_count, central_command = nil, &block)
        @options = options
        @test_count = test_count
        @central_command = central_command
        @progress_block = block
      end

      def central_command
        @central_command ||= @options.central_command
      end

      def statistics
        ThroughputStatistics.new(@test_count, @start_time, @end_time)
      end

      def process_work_units
        @start_time = Time.now

        @test_count.times do
          central_command.write_work NullWorkUnit.new
        end
 
        results_read = 0
        until results_read == @test_count
          Thread.pass
          result = central_command.take_result
          if result
            results_read += 1 
            @progress_block.call(result) if @progress_block
          end
        end

        @end_time = Time.now

        true
      end
    end
  end
end
