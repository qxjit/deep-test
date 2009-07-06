module DeepTest
  class ResultReader
    def initialize(central_command)
      @central_command = central_command
    end

    def read(original_work_units_by_id)
      work_units_by_id = original_work_units_by_id.dup
      errors = 0

      begin
        until errors == work_units_by_id.size
          Thread.pass
          result = @central_command.take_result
          next if result.nil?

          if Agent::Error === result
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
      rescue CentralCommand::NoAgentsRunningError
        FailureMessage.show "DeepTest Agents Are Not Running", <<-end_msg
          DeepTest's test running agents have not contacted the 
          server to indicate they are still running.
          Shutting down the test run on the assumption that they have died. 
        end_msg
      end

      work_units_by_id
    end
  end
end
