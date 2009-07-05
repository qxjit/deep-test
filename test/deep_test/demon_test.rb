require File.dirname(__FILE__) + '/../test_helper'

module DeepTest
  unit_tests do
    class ProcDemon
      include Demon
      def self.heartbeat_interval; 0.05; end
      def initialize(block); @block = block; end
      def execute; @block.call; end
    end

    test "forked redirects stdout and stderr back to central_command" do
      central_command = FakeCentralCommand.new
      ProcDemon.new(proc do
        puts "hello stdout"
        $stderr.puts "hello stderr"
      end).forked("name", central_command, [])

      assert_equal "hello stdout\n", central_command.stdout.string
      assert_equal "hello stderr\n", central_command.stderr.string
    end

    test "demon starts a heartbeat connected to Medic from CentralCommand" do
      central_command = FakeCentralCommand.new
      warlock = Warlock.new(central_command.remote_reference)
      begin
        warlock.start "name", ProcDemon.new(proc { sleep })
        3.times do |i|
          sleep ProcDemon.heartbeat_interval + central_command.medic.fatal_heartbeat_padding
          assert_equal false, central_command.medic.triage(ProcDemon).fatal?, "no heartbeat on check #{i}"
        end
      ensure
        warlock.stop_demons
      end
    end

    test "demon heartbeat stops once the demon has exited" do
      central_command = FakeCentralCommand.new
      warlock = Warlock.new(central_command.remote_reference)
      begin
        warlock.start "name", ProcDemon.new(proc {})
        warlock.wait_for_all_to_finish
        3.times do
          sleep ProcDemon.heartbeat_interval + central_command.medic.fatal_heartbeat_padding
          assert_equal true, central_command.medic.triage(ProcDemon).fatal?
        end
      ensure
        warlock.stop_demons
      end
    end
  end
end

