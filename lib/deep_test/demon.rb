module DeepTest
  module Demon
    def forked(name, options, demon_args)
      ProxyIO.replace_stdout_stderr!(Telegraph::Wire.connect(options.origin_hostname, options.telegraph_port)) do
        begin
          catch(:exit_demon) do
            Signal.trap("TERM") { throw :exit_demon }
            execute *demon_args
          end
        rescue SystemExit => e
          raise
        rescue Exception => e
          FailureMessage.show self.class.name, "Process #{Process.pid} exiting with excetion: #{e.class}: #{e.message}"
          raise
        end
      end
    end

    def execute(*args)
      raise "#{self.class} must implement the execute method to be a Demon"
    end
  end
end
