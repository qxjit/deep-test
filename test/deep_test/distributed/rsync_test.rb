require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "pull execute rsync with using source as remote location" do
    options = DeepTest::Options.new(:sync_options => {:source => "source"})

    DeepTest::Distributed::RSync.expects(:system).
       with("rsync -az --delete host:source/ destination").returns(true)

    DeepTest::Distributed::RSync.pull('host', options, "destination")
  end

  test "push executes rsync with using destination as remote location" do
    options = DeepTest::Options.new(:sync_options => {:source => "source"})

    DeepTest::Distributed::RSync.expects(:system).
       with("rsync -az --delete source/ host:destination").returns(true)

    DeepTest::Distributed::RSync.push('host', options, "destination")
  end

  test "raises error if pull fails" do
    DeepTest::Distributed::RSync.expects(:system).returns(false)

    assert_raises(RuntimeError) do
      DeepTest::Distributed::RSync.pull(
        mock,
        DeepTest::Options.new(:sync_options => {:source => "a", :local => true}),
        "destination"
      )
    end
  end

  test "raises error if push fails" do
    DeepTest::Distributed::RSync.expects(:system).returns(false)

    assert_raises(RuntimeError) do
      DeepTest::Distributed::RSync.push(
        mock,
        DeepTest::Options.new(:sync_options => {:source => "a", :local => true}),
        "destination"
      )
    end
  end

  test "include rsync_options in command" do
    options = DeepTest::Options.new(:sync_options => {:local => true,
                                                      :rsync_options => "opt1 opt2"})

    args = DeepTest::Distributed::RSync::Args.new(mock, options)
    assert_equal "rsync -az --delete opt1 opt2 /", args.command("", "")
  end

  test "includes host in remote_location" do
    options = DeepTest::Options.new({})
    args = DeepTest::Distributed::RSync::Args.new('host', options)

    assert_equal "host:source", args.remote_location('source')
  end

  test "separates host and source with double colon if using daemon" do
    options = DeepTest::Options.new(:sync_options => {:daemon => true})
    args = DeepTest::Distributed::RSync::Args.new('host', options)

    assert_equal "host::source", args.remote_location('source')
  end

  test "includes username in source_location if specified" do
    options = DeepTest::Options.new(:sync_options => {:username => "user"})
    args = DeepTest::Distributed::RSync::Args.new('host', options)

    assert_equal "user@host:source", args.remote_location('source')
  end

  test "does not include host in source_location if local is specified" do
    options = DeepTest::Options.new(:sync_options => {:local => true})
    args = DeepTest::Distributed::RSync::Args.new(mock, options)

    assert_equal "source", args.remote_location('source')
  end
end
