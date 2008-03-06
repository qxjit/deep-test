module DeepTest
  class Worker
    def initialize(blackboard)
      @blackboard = blackboard
    end

    def run
      while work_unit = @blackboard.take_work
        @blackboard.write_result work_unit.run
      end
    end
  end
end
