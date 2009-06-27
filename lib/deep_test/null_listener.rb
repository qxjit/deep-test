module DeepTest
  #
  # Listener that implements no-ops for all callbacks that DeepTest supports.
  #
  class NullListener
    #
    # Before DeepTest synchronizes any code during a distributed run,
    # before_sync is called.  If DeepTest is not running distributed,
    # before_sync is never called.
    # 
    def before_sync
    end

    #
    # Before DeepTest starts any agents, it instantiates a listener and
    # invokes this method.  No other callbacks are made to the listener
    # instance receiving this message. 
    #
    def before_starting_agents
    end

    #
    # A separate listener instance is created in each agent process and
    # notified that the agent is starting.  The agent for the process is
    # provided for the listener to use.  If you are using 3 agents, this
    # method is invoked 3 times on 3 distinct instances.  These instances
    # will also receive the starting_work and finished_work callbacks for
    # the agent provided.
    #
    def starting(agent)
    end

    #
    # Each time a agent takes a work unit, it calls this method before
    # doing the work.  In total, this method will be called as many times
    # as there are work units.  The listener instance that received the
    # starting callback with the agent provided here is the same instance
    # that receives this message.
    #
    # Because each work processes work units in a serial fashion, the
    # listener will receive a finished_work message before another
    # starting_work message.
    #
    def starting_work(agent, work_unit)
    end

    #
    # Each time a agent finishes computing a result for a work unit, 
    # it calls this method before sending that result back to the server.
    # In total, this method will be called as many times
    # as there are work units.  The listener instance that received the
    # starting callback with the agent provided here is the same instance
    # that receives this message.
    #
    # Because each work processes work units in a serial fashion, the
    # listener will receive a starting_work message before another
    # finished_work message.
    #
    def finished_work(agent, work_unit, result)
    end
  end
end
