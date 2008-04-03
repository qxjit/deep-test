require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "executes rsync with source and destination" do
    options = DeepTest::Options.new(:sync_options => {:source => "source", 
                                                      :local => true})

    DeepTest::Distributed::RSync.expects(:system).
       with("rsync -az --delete source/ destination").returns(true)

    DeepTest::Distributed::RSync.sync(mock, options, "destination")
  end

  test "executes non-local rsync with ssh login" do
    options = DeepTest::Options.new(:sync_options => {:source => "source",
                                                      :password => "the_password"})

    DeepTest::Distributed::SSHLogin.expects(:system).
       with("the_password", "rsync -az --delete host:source/ destination").returns(true)

    DeepTest::Distributed::RSync.sync(mock(:address => 'host'), options, "destination")
  end

  test "raises error if sync fails" do
    DeepTest::Distributed::RSync.expects(:system).returns(false)

    assert_raises(RuntimeError) do
      DeepTest::Distributed::RSync.sync(
        mock,
        DeepTest::Options.new(:sync_options => {:source => "a", :local => true}),
        "destination"
      )
    end
  end

  test "include rsync_options in command" do
    options = DeepTest::Options.new(:sync_options => {:source => "source", 
                                                      :local => true,
                                                      :rsync_options => "opt1 opt2"})

    args = DeepTest::Distributed::RSync::Args.new(mock, options)
    assert_equal "rsync -az --delete opt1 opt2 source/", args.command("")
  end

  test "includes host in source_location" do
    options = DeepTest::Options.new(:sync_options => {:source => "source"})
    args = DeepTest::Distributed::RSync::Args.new(mock(:address => 'host'), 
                                                  options)

    assert_equal "host:source", args.source_location
  end

  test "separates host and source with double colon if using daemon" do
    options = DeepTest::Options.new(
      :sync_options => {:source => "source", :daemon => true}
    )
    args = DeepTest::Distributed::RSync::Args.new(mock(:address => 'host'), 
                                                  options)

    assert_equal "host::source", args.source_location
  end

  test "includes username in source_location if specified" do
    options = DeepTest::Options.new(:sync_options => {:source => "source", 
                                                      :username => "user"})
    args = DeepTest::Distributed::RSync::Args.new(mock(:address => 'host'),
                                                  options)

    assert_equal "user@host:source", args.source_location
  end

  test "does not include host in source_location if local is specified" do
    options = DeepTest::Options.new(:sync_options => {:source => "source", 
                                                      :local => "true"})
    args = DeepTest::Distributed::RSync::Args.new(mock, options)

    assert_equal "source", args.source_location
  end
end
