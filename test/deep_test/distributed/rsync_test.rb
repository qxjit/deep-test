require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "executes rsync with source and destination" do
    options = DeepTest::Options.new(:sync_options => {:source => "source", 
                                                      :local => true})

    DeepTest::Distributed::RSync.expects(:system).
       with("rsync -az --delete source/ destination")

    DeepTest::Distributed::RSync.sync(options, "destination")
  end

  test "executes non-local rsync with ssh login" do
    Socket.stubs(:gethostname).returns("host")
    options = DeepTest::Options.new(:sync_options => {:source => "source",
                                                      :password => "the_password"})

    DeepTest::Distributed::SSHLogin.expects(:system).
       with("the_password", "rsync -az --delete host:source/ destination")

    DeepTest::Distributed::RSync.sync(options, "destination")
  end

  test "include rsync_options in command" do
    options = DeepTest::Options.new(:sync_options => {:source => "source", 
                                                      :local => true,
                                                      :rsync_options => "opt1 opt2"})

    args = DeepTest::Distributed::RSync::Args.new(options)
    assert_equal "rsync -az --delete opt1 opt2 source/", args.command("")
  end

  test "includes host in source_location" do
    Socket.stubs(:gethostname).returns("host")
    options = DeepTest::Options.new(:sync_options => {:source => "source"})
    args = DeepTest::Distributed::RSync::Args.new(options)

    assert_equal "host:source", args.source_location
  end

  test "includes username in source_location if specified" do
    Socket.stubs(:gethostname).returns("host")
    options = DeepTest::Options.new(:sync_options => {:source => "source", 
                                                      :username => "user"})
    args = DeepTest::Distributed::RSync::Args.new(options)

    assert_equal "user@host:source", args.source_location
  end

  test "does not include host in source_location if local is specified" do
    options = DeepTest::Options.new(:sync_options => {:source => "source", 
                                                      :local => "true"})
    args = DeepTest::Distributed::RSync::Args.new(options)

    assert_equal "source", args.source_location
  end
end
