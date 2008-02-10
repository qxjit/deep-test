module DeepTest
  class Logger < ::Logger
    def initialize(*args)
      super
      self.formatter = proc { |severity, time, progname, msg| "#{msg}\n" }
      self.level = Logger::INFO
    end
  end
end
