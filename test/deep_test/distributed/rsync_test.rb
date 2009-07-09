require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "pull execute rsync with using source as remote location" do
        RSync.expects(:system).
           with("rsync -az --delete host:source/ destination").returns(true)

        RSync.pull('host', {:source => "source"}, "destination")
      end

      test "push executes rsync with using destination as remote location" do
        RSync.expects(:system).
           with("rsync -az --delete source/ host:destination").returns(true)

        RSync.push('host', {:source => "source"}, "destination")
      end

      test "raises error if pull fails" do
        RSync.expects(:system).returns(false)

        assert_raises(RuntimeError) do
          RSync.pull(mock, {:source => "a", :local => true}, "destination")
        end
      end

      test "raises error if push fails" do
        RSync.expects(:system).returns(false)

        assert_raises(RuntimeError) do
          RSync.push(mock, {:source => "a", :local => true}, "destination")
        end
      end

      test "include rsync_options in command" do
        args = RSync::Args.new(mock, {:local => true, :rsync_options => "opt1 opt2"})
        assert_equal "rsync -az --delete opt1 opt2 /", args.command("", "")
      end

      test "includes host in remote_location" do
        args = RSync::Args.new('host', {})
        assert_equal "host:source", args.remote_location('source')
      end

      test "separates host and source with double colon if using daemon" do
        args = RSync::Args.new('host', {:daemon => true})
        assert_equal "host::source", args.remote_location('source')
      end

      test "includes username in source_location if specified" do
        args = RSync::Args.new('host', {:username => "user"})
        assert_equal "user@host:source", args.remote_location('source')
      end

      test "does not include host in source_location if local is specified" do
        args = RSync::Args.new(mock, {:local => true})
        assert_equal "source", args.remote_location('source')
      end
    end
  end
end
