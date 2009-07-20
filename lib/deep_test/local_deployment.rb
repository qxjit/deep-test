module DeepTest
  class LocalDeployment
    attr_reader :warlock

    def initialize(options, agent_class = DeepTest::Agent)
      @options = options
      @agent_class = agent_class
    end

    def warlock
      @warlock ||= Warlock.new @options
    end

    def load_files(files)
      files.each {|f| load f}
    end

    def deploy_agents
      DeepTest.logger.debug { "Deploying #{number_of_agents} #{@agent_class}s" }
      each_agent do |agent_num|
        warlock.start "agent #{agent_num}", @agent_class.new(agent_num, @options, @options.new_listener_list)
      end        
    end

    def number_of_agents
      @options.number_of_agents
    end

    private

    def each_agent
      number_of_agents.to_i.times { |agent_num| yield agent_num }
    end
  end
end
