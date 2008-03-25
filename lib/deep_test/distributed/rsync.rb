module DeepTest
  module Distributed
    class RSync
      def self.sync(options, destination)
        command = Args.new(options).command(destination)
        DeepTest.logger.debug("rsycing: #{command}")
        if options.sync_options[:local]
          system command
        else
          SSHLogin.system options.sync_options[:password], command
        end
      end

      class Args
        def initialize(options)
          @options = options
          @sync_options = options.sync_options
        end

        def command(destination)
          # The '/' after source tells rsync to copy the contents
          # of source to destination, rather than the source directory
          # itself
          "rsync -az --delete #{@sync_options[:rsync_options]} #{source_location}/ #{destination}".strip.squeeze(" ")
        end

        def source_location
          source = ""
          unless @sync_options[:local]
            source << @sync_options[:username] << '@' if @sync_options[:username]
            source << @options.origin_hostname << ':' 
          end
          source << @sync_options[:source]
        end
      end
    end
  end
end
