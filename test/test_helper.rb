require 'rubygems'
require 'test/unit'
require 'dust'
require 'mocha'
require 'set'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../lib")
require "deep_test"

require File.dirname(__FILE__) + "/../infrastructure/load"

class SomeCustomException < RuntimeError
end

class Test::Unit::TestCase
  def setup
    @old_logger = DeepTest.logger
    DeepTest.logger = TestLogger.new
    DynamicTeardown.setup
  end

  def teardown
    DeepTest.logger = @old_logger if @old_logger
    DynamicTeardown.teardown
  end

  def at(time, &block)
    Timewarp.freeze(time, &block)
  end
end
