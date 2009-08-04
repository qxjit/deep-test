require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "generates a local working copy path based on host and source of request" do
        Socket.stubs(:gethostname).returns("myhost")
        Telegraph::Wire.stubs(:connect).returns :wire
        landing_ship = LandingShip.new(:address => "host")
        options = Options.new(:sync_options => {:source => "/my/local/dir"})
        RSync.expects(:push).with("host", options.sync_options, "/tmp/myhost_my_local_dir")
        landing_ship.push_code(options)
      end

      test "establish_beachhead launches beachhead process on remote machine" do
        Socket.stubs(:gethostname).returns("myhost")
        Telegraph::Wire.stubs(:connect).returns :wire
        landing_ship = LandingShip.new(:address => "remote_host")
        options = Options.new(:sync_options => {:source => "/my/local/dir"})

        landing_ship.expects(:`).with(
          "ssh -4 remote_host " + 
          "'#{ShellEnvironment.like_login} && cd /tmp/myhost_my_local_dir && " + 
          "OPTIONS=#{options.to_command_line} " + 
          "ruby lib/deep_test/distributed/establish_beachhead.rb' 2>&1"
        ).returns("blah blah\nBeachhead port: 9999\nblah")

        landing_ship.establish_beachhead(options)
      end

      test "establish_beachhead launches beachhead process on remote machine with usernames specified in sync_options" do
        Socket.stubs(:gethostname).returns("myhost")
        Telegraph::Wire.stubs(:connect).returns :wire
        landing_ship = LandingShip.new(:address => "remote_host")
        options = Options.new(:sync_options => {:username => "me", :source => "/my/local/dir"})

        landing_ship.expects(:`).with(
          "ssh -4 remote_host -l me " + 
          "'#{ShellEnvironment.like_login} && cd /tmp/myhost_my_local_dir && " + 
          "OPTIONS=#{options.to_command_line} " + 
          "ruby lib/deep_test/distributed/establish_beachhead.rb' 2>&1"
        ).returns("blah blah\nBeachhead port: 9999\nblah")

        landing_ship.establish_beachhead(options)
      end
    end
  end
end
