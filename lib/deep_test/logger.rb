module DeepTest
  class Logger < ::Logger
    def initialize(*args)
      super
      self.formatter = proc { |severity, time, progname, msg| "[DeepTest] #{msg}\n" }
      self.level = configured_log_level
    end

    def configured_log_level
      if ENV['DEEP_TEST_LOG_LEVEL']
        Logger.const_get(ENV['DEEP_TEST_LOG_LEVEL'])
      else
        Logger::INFO
      end
    end
  end
end
