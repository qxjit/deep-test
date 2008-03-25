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
require File.dirname(__FILE__) + "/../spec/thread_worker"

class SomeCustomException < RuntimeError
end
