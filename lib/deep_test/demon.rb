module DeepTest
  module Demon
    def forked(name, central_command, demon_args)
      ProxyIO.replace_stdout_stderr!(central_command.stdout, central_command.stderr) do
        begin
          catch(:exit_demon) do
            Signal.trap("TERM") { throw :exit_demon }
            heartbeat = Heartbeat.start self, central_command.medic.assign_monitor(self.class), self.class.heartbeat_interval
            begin
              execute *demon_args
            ensure
              heartbeat.stop
            end
          end
        rescue Exception => e
          DeepTest.logger.debug { "Exception in #{name} (#{Process.pid}): #{e.message}" }
          raise
        end
      end
    end

    def execute(*args)
      raise "#{self.class} must implement the execute method to be a Demon"
    end

    def heartbeat_stopped
      raise "#{self.class} must implement the heartbeat_stopped method to be a Demon"
    end

    module ClassMethods
      def heartbeat_interval
        3
      end

      def is_lack_of_heartbeat_fatal?(last_beat_time, fatality_padding_time)
        (Time.now - last_beat_time) > (heartbeat_interval + fatality_padding_time)
      end
    end

    def self.included(mod)
      mod.extend ClassMethods
    end
  end
end
