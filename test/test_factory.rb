module TestFactory
  def self.failing_test
    test_class do
      def test_failing
        assert_equal 1, 0
      end
    end.new(:test_failing)
  end

  def self.passed_result
    result = Test::Unit::TestResult.new
    result.add_run
    result.add_assertion
    result
  end

  def self.passing_test
    test_class do
      def test_passing
        assert_equal 0, 0
      end
    end.new(:test_passing)
  end
  
  def self.passing_test_with_stdout
    test_class do
      def test_passing_with_stdout
        print "message printed to stdout"
        assert true
      end
    end.new :test_passing_with_stdout
  end
  
  def self.deadlock_once_test
    test_class do
      def test_deadlock_once
        if @deadlocked
          assert true
        else
          @deadlocked = true
          raise FakeDeadlockError.new
        end
      end
    end.new :test_deadlock_once
  end
  
  def self.deadlock_always_test
    test_class do
      def test_deadlock_always
        raise FakeDeadlockError.new
      end
    end.new :test_deadlock_always
  end

  def self.suite
    Test::Unit::TestSuite.new
  end

  def self.test_class(&block)
    test_class = Class.new(Test::Unit::TestCase)

    class_name = external_caller.upcase.gsub(/[^A-Z0-9]/,"_").sub(/^_*/,'')
    const_set(class_name, test_class)

    test_class.class_eval &block
    test_class
  end

  def self.external_caller
    caller.each do |trace_line|
      return trace_line unless trace_line =~ /test_factory.rb/
    end
  end
end
