require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "pull execute rsync with using source as remote location" do
        options = Options.new(:sync_options => {:source => "source"})

        RSync.expects(:system).
           with("rsync -az --delete host:source/ destination").returns(true)

        RSync.pull('host', options, "destination")
      end

      test "push executes rsync with using destination as remote location" do
        options = Options.new(:sync_options => {:source => "source"})

        RSync.expects(:system).
           with("rsync -az --delete source/ host:destination").returns(true)

        RSync.push('host', options, "destination")
      end

      test "raises error if pull fails" do
        RSync.expects(:system).returns(false)

        assert_raises(RuntimeError) do
          RSync.pull(
            mock,
            Options.new(:sync_options => {:source => "a", :local => true}),
            "destination"
          )
        end
      end

      test "raises error if push fails" do
        RSync.expects(:system).returns(false)

        assert_raises(RuntimeError) do
          RSync.push(
            mock,
            Options.new(:sync_options => {:source => "a", :local => true}),
            "destination"
          )
        end
      end

      test "include rsync_options in command" do
        options = Options.new(:sync_options => {:local => true,
                                                :rsync_options => "opt1 opt2"})

        args = RSync::Args.new(mock, options)
        assert_equal "rsync -az --delete opt1 opt2 /", args.command("", "")
      end

      test "includes host in remote_location" do
        options = Options.new({})
        args = RSync::Args.new('host', options)

        assert_equal "host:source", args.remote_location('source')
      end

      test "separates host and source with double colon if using daemon" do
        options = Options.new(:sync_options => {:daemon => true})
        args = RSync::Args.new('host', options)

        assert_equal "host::source", args.remote_location('source')
      end

      test "includes username in source_location if specified" do
        options = Options.new(:sync_options => {:username => "user"})
        args = RSync::Args.new('host', options)

        assert_equal "user@host:source", args.remote_location('source')
      end

      test "does not include host in source_location if local is specified" do
        options = Options.new(:sync_options => {:local => true})
        args = RSync::Args.new(mock, options)

        assert_equal "source", args.remote_location('source')
      end
    end
  end
end
