module DeepTest
  class ProxyIO < StringIO
    def initialize(target)
      @target = target
      super("")
    end

    def write(*args)
      super
      @target.write string
      self.string = ""
    end

    def flush
      @target.flush
    end

    def reopen(*args)
      @target.reopen *args
    end

    def self.replace_stdout_stderr!(new_stdout, new_stderr)
      old_stdout_const, old_stdout_global = STDOUT, $stdout
      old_stderr_const, old_stderr_global = STDERR, $stderr

      supress_warnings { Object.const_set :STDOUT, ProxyIO.new(new_stdout) }
      $stdout = STDOUT

      supress_warnings { Object.const_set :STDERR, ProxyIO.new(new_stderr) }
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
  end
end
