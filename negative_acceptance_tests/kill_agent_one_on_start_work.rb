class KillAgentOneOnStartWork
    def before_sync
    end
    def before_starting_agents
    end
    def starting(agent)
    end
    def starting_work(agent, work_unit)
      if agent.number == 1
        puts "Killing Agent 1 to see if CentralCommand redispatches work"
        exit!(0) 
      end
    end
    def finished_work(agent, work_unit, result)
    end
end
