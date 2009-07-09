require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "push executes rsync with using destination as remote location" do
        RSync.expects(:system).
           with("rsync -az --delete #{DeepTest::LIB_ROOT} source host:destination").returns(true)

        RSync.push('host', {:source => "source"}, "destination")
      end

      test "raises error if push fails" do
        RSync.expects(:system).returns(false)

        assert_raises(RuntimeError) do
          RSync.push(mock, {:source => "a", :local => true}, "destination")
        end
      end

      test "include rsync_options in command" do
        args = RSync::Args.new(mock, {:local => true, :rsync_options => "opt1 opt2"})
        assert_equal "rsync -az --delete opt1 opt2 #{DeepTest::LIB_ROOT}", args.command("", "")
      end

      test "includes host in remote_location" do
        args = RSync::Args.new('host', {})
        assert_equal "host:dest", args.remote_location('dest')
      end

      test "separates host and dest with double colon if using daemon" do
        args = RSync::Args.new('host', {:daemon => true})
        assert_equal "host::dest", args.remote_location('dest')
      end

      test "includes username in dest_location if specified" do
        args = RSync::Args.new('host', {:username => "user"})
        assert_equal "user@host:dest", args.remote_location('dest')
      end

      test "does not include host in dest_location if local is specified" do
        args = RSync::Args.new(mock, {:local => true})
        assert_equal "dest", args.remote_location('dest')
      end
    end
  end
end
