require File.dirname(__FILE__) + '/../test_helper'

module DeepTest
  unit_tests do
    class ProcDemon
      include Demon
      def initialize(block); @block = block; end
      def execute; @block.call; end
    end

    test "forked redirects output back to central command" do
      options = Options.new({})
      operator = TestOperator.listen(options)
      ProcDemon.new(proc do
        puts "hello stdout"
      end).forked("name", options, FakeCentralCommand.new, [])

      assert_equal ProxyIO::Stdout::Output.new("hello stdout"), operator.next_message[0]
      assert_equal ProxyIO::Stdout::Output.new("\n"), operator.next_message[0]
    end
  end
end

