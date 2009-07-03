require File.dirname(__FILE__) + '/../test_helper'

module DeepTest
  unit_tests do
    class ProcDemon
      include Demon

      def initialize(block)
        @block = block
      end

      def execute
        @block.call
      end
    end

    test "forked redirects stdout and stderr back to central_command" do
      central_command = SimpleTestCentralCommand.new
      ProcDemon.new(proc do
        puts "hello stdout"
        $stderr.puts "hello stderr"
      end).forked("name", central_command, [])

      assert_equal "hello stdout\n", central_command.stdout.string
      assert_equal "hello stderr\n", central_command.stderr.string
    end
  end
end

