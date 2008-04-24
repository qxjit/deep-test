module DeepTest
  module Distributed
    class RSync
      def self.sync(connection_info, options, destination)
        command = Args.new(connection_info, options).command(destination)
        DeepTest.logger.debug("rsycing: #{command}")
        successful = system command
        raise "RSync Failed!!" unless successful
      end

      class Args
        def initialize(connection_info, options)
          @connection_info = connection_info
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
            source << @connection_info.address
            source << (@sync_options[:daemon] ? '::' : ':')
          end
          source << @sync_options[:source]
        end
      end
    end
  end
end
