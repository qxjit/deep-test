require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "info log level by default" do
      assert_equal Logger::INFO, DeepTest.logger.level
    end
    
    test "formatter uses msg only" do
      time = Time.parse("2009-09-22 12:01:33")
      assert_equal "[DeepTest@#{Socket.gethostname}] 2009-09-22 12:01:33 my_msg\n", DeepTest.logger.formatter.call(nil, time, nil, "my_msg")
    end

    Logger::Severity.constants.each do |severity|
      test "#{severity.downcase} can not be called with any arguments" do
        logger = Logger.new stub_everything
        assert_raises(ArgumentError) { logger.send severity.downcase, "a"  }
      end

      THE_DATE = '\d{4}-\d\d-\d\d \d\d:\d\d:\d\d' unless defined?(THE_DATE)

      test "#{severity.downcase} can be called with a block" do
        logger = Logger.new(out = StringIO.new)
        logger.level = Logger.const_get(severity)
        logger.send(severity.downcase) { "a" }
        assert_match /\[DeepTest@#{Socket.gethostname}\] #{THE_DATE} a\n/, out.string
      end

      test "#{severity.downcase} rescues errors from block and logs them" do
        logger = Logger.new(out = StringIO.new)
        logger.level = Logger.const_get(severity)
        logger.send(severity.downcase) { raise Exception, "e" }
        assert_match /\[DeepTest@#{Socket.gethostname}\] #{THE_DATE} Exception: e occurred logging on #{__FILE__}:#{__LINE__ - 1}:in `send'\n/,
                    out.string
      end
    end
  end
end
