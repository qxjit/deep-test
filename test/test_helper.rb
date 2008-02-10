require 'rubygems'
require 'test/unit'
require 'dust'
require 'mocha'
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/lib")
require "deep_test"

require File.dirname(__FILE__) + "/simple_test_blackboard"
require File.dirname(__FILE__) + "/test_factory"

class SomeCustomException < RuntimeError
end

unless defined?(ActiveRecord::StatementInvalid)
  module ActiveRecord
    class StatementInvalid < StandardError
    end
  end
end
