require File.dirname(__FILE__) + '/../test_helper'

module DeepTest
  unit_tests do
    test "running? is true if sending kill(0, pid) does not fail" do
      warlock = Warlock.new mock
      Process.expects(:kill).with(0, :pid)
      assert_equal true, warlock.running?(:pid)
    end
    
    test "running? is false if Process.kill(0, pid) raises Errno::ESRCH" do
      warlock = Warlock.new mock
      Process.stubs(:kill).raises(Errno::ESRCH)
      assert_equal false, warlock.running?(:pid)
    end
    
    test "running? is true if Process.kill raises Exception" do
      warlock = Warlock.new mock
      Process.stubs(:kill).raises(Exception)
      assert_equal true, warlock.running?(:pid)
    end

    test "demon_count is 0 initially" do
      assert_equal 0, Warlock.new(mock).demon_count
    end

    test "add_demon increases demon_count by 1" do
      warlock = Warlock.new mock
      warlock.send(:add_demon, "name", 1)
      assert_equal 1, warlock.demon_count
    end

    test "remove_demon increases demon_count by 1" do
      warlock = Warlock.new mock
      warlock.send(:add_demon, "name", 1)
      warlock.send(:remove_demon, "name", 1)
      assert_equal 0, warlock.demon_count
    end

    test "start redirects stdout and stderr back to central_command" do
      central_command = SimpleTestCentralCommand.new
      central_command.with_drb_server do |remote_reference|
        warlock = Warlock.new remote_reference
        begin
          warlock.start("test") do
            puts "hello stdout"
            $stderr.puts "hello stderr"
          end
          warlock.wait_for_all_to_finish
        ensure
          warlock.stop_demons
        end
      end

      assert_equal "hello stdout\n", central_command.stdout.string
      assert_equal "hello stderr\n", central_command.stderr.string
    end

    test "start reopens original stdout and stderr to /dev/null if detach_io is true" do
      test_stdout, test_stderr = Tempfile.new("stdout"), Tempfile.new("stderr")
      central_command = SimpleTestCentralCommand.new
      central_command.with_drb_server do |remote_reference|
        warlock = Warlock.new remote_reference
        begin
          require 'tempfile'
          ProxyIO.replace_stdout_stderr! test_stdout, test_stderr do
            warlock.start("test", :detach_io => true) do
              test_stdout.puts "hello stdout"
              test_stderr.puts "hello stderr"
            end
            warlock.wait_for_all_to_finish
          end
        ensure
          warlock.stop_demons
        end
      end

      test_stdout.rewind; test_stderr.rewind
      assert_equal "", test_stdout.read
      assert_equal "", test_stderr.read
    end

    test "start leave original stdout and untouched if detach_io is false" do
      test_stdout, test_stderr = Tempfile.new("stdout"), Tempfile.new("stderr")
      central_command = SimpleTestCentralCommand.new
      central_command.with_drb_server do |remote_reference|
        warlock = Warlock.new remote_reference
        begin
          require 'tempfile'
          ProxyIO.replace_stdout_stderr! test_stdout, test_stderr do
            warlock.start("test", :detach_io => false) do
              test_stdout.puts "hello stdout"
              test_stderr.puts "hello stderr"
            end
            warlock.wait_for_all_to_finish
          end
        ensure
          warlock.stop_demons
        end
      end

      test_stdout.rewind; test_stderr.rewind
      assert_equal "hello stdout\n", test_stdout.read
      assert_equal "hello stderr\n", test_stderr.read
    end
  end
end
