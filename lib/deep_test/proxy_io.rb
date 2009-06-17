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

    def self.replace_stdout!(target)
      old_stdout_const, old_stdout_global = STDOUT, $stdout

      supress_warnings { Object.const_set :STDOUT, ProxyIO.new(target) }
      $stdout = STDOUT

      yield
    ensure
      $stdout = old_stdout_global
      supress_warnings { Object.const_set :STDOUT, old_stdout_const }
    end

    def self.supress_warnings
      old_verbose, $VERBOSE = $VERBOSE, nil
      yield
    ensure
      $VERBOSE = old_verbose
    end
  end
end
