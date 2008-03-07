module DeepTest
  class NullWorkerListener
    def starting(worker)
    end

    def starting_work(worker, work_unit)
    end

    def finished_work(worker, work_unit, result)
    end
  end
end
