module DeepTest
  class ThreadAgent < Agent
    attr_reader :work_done

    def initialize(options)
      super(0, options, ListenerList.new([]))
      @thread = Thread.new { execute }
      @work_done = 0
    end

    def wait_until_done
      Timeout.timeout(5) {@thread.join}
      @thread.kill if @thread.alive?
    end

    def send_result(*args)
      super
      @work_done += 1
    end
  end
end
