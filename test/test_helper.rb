require 'rubygems'
require 'test/unit'
require 'dust'
require 'mocha'
require 'daemons'
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/lib")
require "deep_test"

module TestFactory
  def self.failing_test
    test_class = Class.new(Test::Unit::TestCase) do
      def test_failing
        assert_equal 1, 0
      end
    end
    test_class.new(:test_failing)
  end

  def self.passed_result
    result = Test::Unit::TestResult.new
    result.add_run
    result.add_assertion
    result
  end

  def self.passing_test
    test_class = Class.new(Test::Unit::TestCase) do
      def test_passing
        assert_equal 0, 0
      end
    end
    test_class.new(:test_passing)
  end
  
  def self.passing_test_with_stdout
    test_class = Class.new(Test::Unit::TestCase) do
      def test_passing_with_stdout
        print "message printed to stdout"
        assert true
      end
    end
    test_class.new :test_passing_with_stdout
  end
  
  def self.deadlock_once_test
    test_class = Class.new(Test::Unit::TestCase) do
      def test_deadlock_once
        if @deadlocked
          assert true
        else
          @deadlocked = true
          raise ActiveRecord::StatementInvalid.new("Deadlock found when trying to get lock")
        end
      end
    end
    test_class.new :test_deadlock_once
  end
  
  def self.deadlock_always_test
    test_class = Class.new(Test::Unit::TestCase) do
      def test_deadlock_always
        raise ActiveRecord::StatementInvalid.new("Deadlock found when trying to get lock")
      end
    end
    test_class.new :test_deadlock_always
  end

  def self.suite
    Test::Unit::TestSuite.new
  end
end

class SomeCustomException < RuntimeError
end

unless defined?(ActiveRecord::StatementInvalid)
  module ActiveRecord
    class StatementInvalid < StandardError
    end
  end
end
