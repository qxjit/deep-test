require 'rubygems'
require 'test/unit'
require 'dust'
require 'mocha'
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

  def self.suite
    Test::Unit::TestSuite.new
  end
end

class SomeCustomException < RuntimeError
end
