require 'logger'

module Telegraph
  module Logging
    def self.logger
      @logger ||= begin
        l = Logger.new($stdout)
        l.level = Logger.const_get((ENV['TELEGRAPH_LOG_LEVEL'] || 'info').upcase)
        l.formatter = proc do |sev, time, progmane, msg|
          "[#{time.strftime "%T"}] (pid #{Process.pid}) #{msg}\n"
        end
        l
      end
    end

    def debug
      Logging.logger.debug { "#{self.class}: #{yield}" }
    end
  end
end
