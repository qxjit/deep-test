module DeepTest
  class ResultReader
    def initialize(blackboard)
      @blackboard = blackboard
    end

    def read(count)
      until count == 0
        Thread.pass
        result = @blackboard.take_result
        next if result.nil?
        count -= 1

        if Worker::Error === result
          puts result
        else
          if result.respond_to?(:output) && (output = result.output)
            print output
          end

          yield result
        end
      end
    end
  end
end
