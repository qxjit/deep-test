module DeepTest
  class Worker
    def initialize(blackboard, worker_listener)
      @blackboard = blackboard
      @listener = worker_listener
    end

    def run
      @listener.starting(self)
      while work_unit = @blackboard.take_work
        @listener.starting_work(self, work_unit)
        result = work_unit.run
        @listener.finished_work(self, work_unit, result)
        @blackboard.write_result result
      end
    end
  end
end
