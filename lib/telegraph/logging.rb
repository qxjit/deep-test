require 'logger'

module Telegraph
  module Logging
    def self.logger
      @logger ||= begin
        l = Logger.new($stdout)
        l.level = Logger::INFO
        l.formatter = proc do |sev, time, progmane, msg|
          "[#{time.strftime "%T"}] #{msg}\n"
        end
        l
      end
    end

    def debug
      Logging.logger.debug { "#{self.class}: #{yield}" }
    end
  end
end
