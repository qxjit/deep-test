class ThreadWorker
  attr_reader :work_done

  def initialize(central_command, expected_work)
    @central_command, @expected_work = central_command, expected_work
    @thread = Thread.new {run}
  end

  def wait_until_done
    Timeout.timeout(5) {@thread.join}
    @thread.kill if @thread.alive?
  end

  def run
    @work_done = 0
    until @work_done >= @expected_work
      Thread.pass
      work = @central_command.take_work
      if work
        @central_command.write_result work.run 
        @work_done += 1
      end
    end
  end
end
