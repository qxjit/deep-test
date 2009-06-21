require 'rubygems'
require 'test/unit'
require 'dust'
require 'mocha'
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")
require "deep_test"
require 'set'

require File.dirname(__FILE__) + "/fake_deadlock_error"
require File.dirname(__FILE__) + "/simple_test_blackboard"
require File.dirname(__FILE__) + "/test_factory"
require File.dirname(__FILE__) + "/test_logger"
require File.dirname(__FILE__) + "/../spec/thread_worker"

class SomeCustomException < RuntimeError
end

class Test::Unit::TestCase
  def setup
    @old_logger = DeepTest.logger
    DeepTest.logger = TestLogger.new
  end

  def teardown
    DeepTest.logger = @old_logger if @old_logger
  end
end
