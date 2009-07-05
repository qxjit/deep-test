module DeepTest
  module Demon
    def forked(name, central_command, demon_args)
      ProxyIO.replace_stdout_stderr!(central_command.stdout, central_command.stderr) do
        catch(:exit_demon) do
          Signal.trap("TERM") { throw :exit_demon }
          Heartbeat.start central_command.medic.assign_monitor(self.class), self.class.heartbeat_interval

          begin
            execute *demon_args
          rescue Exception => e
            DeepTest.logger.debug { "Exception in #{name} (#{Process.pid}): #{e.message}" }
            raise
          end
        end
      end
    end

    def execute(*args)
      raise "#{self.class} must implement the execute method to be a Demon"
    end

    module ClassMethods
      def heartbeat_interval
        3
      end
    end

    def self.included(mod)
      mod.extend ClassMethods
    end
  end
end
