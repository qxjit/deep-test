module DeepTest
  module Distributed
    class LandingShip
      def initialize(config)
        @config = config
      end

      def push_code(options)
        path = options.mirror_path(@config[:work_dir])
        RSync.push(@config[:address], options.sync_options, path)
      end

      def establish_beachhead(options)
        command  = "#{ssh_command(options)} '#{spawn_command(options)}' 2>&1"
        DeepTest.logger.debug { "Establishing Beachhed: #{command}" }
        
        output = `#{command}`
        output.each do |line|
          if line =~ /Beachhead port: (.+)/
            @wire = Telegraph::Wire.connect(@config[:address], $1.to_i)
          end
        end
        raise "LandingShip unable to establish Beachhead.  Output from #{@config[:address]} was:\n#{output}" unless @wire
      end

      def load_files(files)
        @wire.send_message Beachhead::LoadFiles.new(files)
      end

      def deploy_agents
        @wire.send_message Beachhead::DeployAgents
        begin
          message = @wire.next_message :timeout => 1
          raise "Unexpected message from Beachhead: #{message.inspect}" unless message == Beachhead::Done
        rescue Telegraph::NoMessageAvailable
          retry
        end
      end

      def ssh_command(options)
        username_option = if options.sync_options[:username]
                            " -l #{options.sync_options[:username]}"
                          else
                            ""
                          end

        "ssh -4 #{@config[:address]}#{username_option}"
      end

      def spawn_command(options)
        "#{ShellEnvironment.like_login} && " + 
        "cd #{options.mirror_path(@config[:work_dir])} && " + 
        "OPTIONS=#{options.to_command_line} " + 
        "ruby lib/deep_test/distributed/establish_beachhead.rb" 
      end
    end
  end
end
