module DeepTest
  #
  # Listener that implements no-ops for all callbacks that DeepTest supports.
  #
  class NullWorkerListener

    #
    # Before DeepTest starts any workers, it instantiates a listener and
    # invokes this method.  No other callbacks are made to the listener
    # instance receiving this message. 
    #
    def before_starting_workers
    end

    #
    # A separate listener instance is created in each worker process and
    # notified that the worker is starting.  The worker for the process is
    # provided for the listener to use.  If you are using 3 workers, this
    # method is invoked 3 times on 3 distinct instances.  These instances
    # will also receive the starting_work and finished_work callbacks for
    # the worker provided.
    #
    def starting(worker)
    end

    #
    # Each time a worker takes a work unit, it calls this method before
    # doing the work.  In total, this method will be called as many times
    # as there are work units.  The listener instance that received the
    # starting callback with the worker provided here is the same instance
    # that receives this message.
    #
    # Because each work processes work units in a serial fashion, the
    # listener will receive a finished_work message before another
    # starting_work message.
    #
    def starting_work(worker, work_unit)
    end

    #
    # Each time a worker finishes computing a result for a work unit, 
    # it calls this method before sending that result back to the server.
    # In total, this method will be called as many times
    # as there are work units.  The listener instance that received the
    # starting callback with the worker provided here is the same instance
    # that receives this message.
    #
    # Because each work processes work units in a serial fashion, the
    # listener will receive a starting_work message before another
    # finished_work message.
    #
    def finished_work(worker, work_unit, result)
    end
  end
end
