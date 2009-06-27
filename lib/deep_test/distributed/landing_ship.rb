module DeepTest
  module Distributed
    class LandingShip
      def initialize(config)
        @config = config
      end

      def push_code(options)
        DeepTest.logger.debug { "mirror sync for #{options.origin_hostname}" }
        path = options.mirror_path(@config[:work_dir])
        DeepTest.logger.debug { "Syncing #{options.sync_options[:source]} to #{path}" }
        RSync.push(@config[:address], options, path)
      end

      def establish_beachhead(options)
        output  = `#{ssh_command(options)} '#{spawn_command(options)}'`
        output.each do |line|
          if line =~ /Beachhead url: (.*)/
            return DRb::DRbObject.new_with_uri($1)
          end
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
        "rake deep_test:establish_beachhead " + 
        "OPTIONS=#{options.to_command_line} HOST=#{@config[:address]}"
      end
    end
  end
end
