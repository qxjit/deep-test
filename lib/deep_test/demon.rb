module DeepTest
  module Demon
    def forked(name, central_command, demon_args)
      ProxyIO.replace_stdout_stderr!(central_command.stdout, central_command.stderr) do
        catch(:exit_demon) do
          Signal.trap("TERM") { throw :exit_demon }

          begin
            execute *demon_args
          rescue Exception => e
            DeepTest.logger.debug { "Exception in #{name} (#{Process.pid}): #{e.message}" }
            raise
          end
        end
      end
    end
  end
end
