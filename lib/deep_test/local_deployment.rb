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
      wait_for_connect_threads = []
      each_agent do |agent_num|
        stream_from_child_process, stream_to_parent_process = IO.pipe
        warlock.start "agent #{agent_num}", @agent_class.new(agent_num, @options, @options.new_listener_list), 
                      stream_from_child_process, stream_to_parent_process
        wait_for_connect_threads << Thread.new do
          stream_to_parent_process.close
          message = stream_from_child_process.read
          stream_from_child_process.close
          raise "Agent was not able to connect: #{message}" unless message == "Connected\n"
        end
      end        

      wait_for_connect_threads.each { |t| t.join }
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
