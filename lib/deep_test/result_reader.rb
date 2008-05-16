module DeepTest
  class ResultReader
    def initialize(blackboard)
      @blackboard = blackboard
    end

    def read(original_work_units_by_id)
      work_units_by_id = original_work_units_by_id.dup
      errors = 0

      begin
        until errors == work_units_by_id.size
          Thread.pass
          result = @blackboard.take_result
          next if result.nil?

          if Worker::Error === result
            puts result
            errors += 1
          else
            if result.respond_to?(:output) && (output = result.output)
              print output
            end

            work_unit = work_units_by_id.delete(result.identifier)
            yield [work_unit, result]
          end
        end
      rescue Server::ResultOverdueError
        DeepTest.logger.error("Results are overdue from server, ending run")
      end

      work_units_by_id
    end
  end
end
