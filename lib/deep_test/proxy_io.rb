module DeepTest
  class ProxyIO < StringIO
    def initialize(output_module, wire)
      @output_module = output_module
      @wire = wire
      super("")
    end

    def write(*args)
      super
      @wire.send_message @output_module::Output.new(string)
      self.string = ""
    end

    def flush
      @wire.send_message @output_module::Flush.new
    end

    def self.replace_stdout_stderr!(wire)
      old_stdout_const, old_stdout_global = STDOUT, $stdout
      old_stderr_const, old_stderr_global = STDERR, $stderr

      supress_warnings { Object.const_set :STDOUT, ProxyIO.new(Stdout, wire) }
      $stdout = STDOUT

      supress_warnings { Object.const_set :STDERR, ProxyIO.new(Stderr, wire) }
      $stderr = STDERR

      yield
    ensure
      $stdout = old_stdout_global
      supress_warnings { Object.const_set :STDOUT, old_stdout_const }

      $stderr = old_stderr_global
      supress_warnings { Object.const_set :STDERR, old_stderr_const }
    end

    def self.supress_warnings
      old_verbose, $VERBOSE = $VERBOSE, nil
      yield
    ensure
      $VERBOSE = old_verbose
    end

    class AbstractOutput
      include CentralCommand::Operation
      attr_reader :s
      def initialize(s); @s = s; end
      def execute; stream.write @s; end
      def ==(other); self.class == other.class && s == other.s; end
    end

    module Stdout
      class Output < AbstractOutput
        def stream; $stdout; end
      end

      class Flush
        include CentralCommand::Operation
        def execute; $stdout.flush; end
      end
    end

    module Stderr
      class Output < AbstractOutput
        def stream; $stderr; end
      end

      class Flush
        include CentralCommand::Operation
        def execute; $stderr.flush; end
      end
    end
  end
end
