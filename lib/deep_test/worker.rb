module DeepTest
  class Worker
    attr_reader :number

    def initialize(number, blackboard, worker_listener)
      @number = number
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
        if ENV['DEEP_TEST_SHOW_WORKER_DOTS'] == 'yes'
          $stdout.print '.'
          $stdout.flush
        end
      end
    end
  end
end
