module DeepTest
  module Distributed
    class RSync
      def self.pull(address, sync_options, destination)
        sync(:pull, address, sync_options, destination)
      end
      
      def self.push(address, sync_options, destination)
        sync(:push, address, sync_options, destination)
      end

      def self.sync(operation, address, sync_options, destination)
        command = Args.new(address, sync_options).send("#{operation}_command", 
                                                  destination)

        DeepTest.logger.debug { "rsycing: #{command}" }
        successful = system command
        raise "RSync Failed!!" unless successful
      end

      class Args
        def initialize(address, sync_options)
          @address = address
          @sync_options = sync_options
        end

        def pull_command(destination)
          command remote_location(@sync_options[:source]), destination
        end

        def push_command(destination)
          command @sync_options[:source], remote_location(destination)
        end

        def command(source, destination)
          # The '/' after source tells rsync to copy the contents
          # of source to destination, rather than the source directory
          # itself
          "rsync -az --delete #{@sync_options[:rsync_options]} #{source}/ #{destination}".strip.squeeze(" ")
        end

        def remote_location(path)
          source = ""
          unless @sync_options[:local]
            source << @sync_options[:username] << '@' if @sync_options[:username]
            source << @address
            source << (@sync_options[:daemon] ? '::' : ':')
          end
          source << path
        end
      end
    end
  end
end
