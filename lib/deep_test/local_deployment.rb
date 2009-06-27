module DeepTest
  class LocalDeployment
    def initialize(options, agent_class = DeepTest::Agent)
      @options = options
      @warlock = Warlock.new
      @agent_class = agent_class
    end

    def load_files(files)
      files.each {|f| load f}
    end

    def central_command
      @options.central_command
    end

    def deploy_agents
      each_agent do |agent_num|
        start_agent(agent_num) do
          ProxyIO.replace_stdout_stderr!(central_command.stdout, central_command.stderr) do
            reseed_random_numbers
            reconnect_to_database
            agent = @agent_class.new(agent_num, central_command, @options.new_listener_list)
            agent.run
          end
        end
      end        
    end

    def terminate_agents
      @warlock.terminate_agents
    end

    def wait_for_completion
      @warlock.wait_for_all_to_finish
    end

    def number_of_agents
      @options.number_of_agents
    end

    private

    def reconnect_to_database
      ActiveRecord::Base.connection.reconnect! if defined?(ActiveRecord::Base)
    end

    def start_agent(agent_num, &blk)
      @warlock.start("agent #{agent_num}", &blk)
    end

    def reseed_random_numbers
      srand
    end

    def each_agent
      number_of_agents.to_i.times { |agent_num| yield agent_num }
    end
  end
end
