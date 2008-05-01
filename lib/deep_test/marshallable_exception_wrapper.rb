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

      begin
        resolved_exception = klass.new resolved_message
      rescue => e
        DeepTest.logger.debug("Unable to instantiation exception class: #{classname}: #{e.message}")
        DeepTest.logger.debug(e.backtrace.join("\n"))

        resolved_exception = UnloadableException.new resolved_message
      end

      resolved_exception.set_backtrace backtrace
      resolved_exception
    end
  end

  class UnloadableException < StandardError; end
end
