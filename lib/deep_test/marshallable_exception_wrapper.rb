module DeepTest
  class MarshallableExceptionWrapper
    attr_reader :classname, :message, :backtrace

    def initialize(exception)
      @classname = exception.class.name
      @message = exception.message
      @backtrace = exception.backtrace
    end

    def ==(other)
      classname == other.classname &&
        message == other.message &&
      backtrace == other.backtrace
    end

    def resolve
      begin
        klass = eval("::" + classname) 
        resolved_message = message
      rescue => e
        DeepTest.logger.debug("Unable to load exception class: #{classname}: #{e.message}")
        DeepTest.logger.debug(e.backtrace.join("\n"))

        klass = UnloadableException
        resolved_message = "#{classname}: #{message}"
      end

      e = klass.new resolved_message
      e.set_backtrace backtrace
      e
    end
  end

  class UnloadableException < StandardError; end
end
