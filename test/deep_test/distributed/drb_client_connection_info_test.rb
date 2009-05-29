require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "returns ipaddress from peeraddr as address" do
        info = nil
        with_drb('client' => mock(:peeraddr => [nil, nil, nil, "ip"])) do
          info = DRbClientConnectionInfo.new
        end

        assert_equal "ip", info.address
      end

      test "raises an error if no drb client is found" do
        with_drb({}) do
          assert_raises(RuntimeError) { DRbClientConnectionInfo.new }
        end
      end

      test "raises an error if no drb info is found" do
        with_drb(nil) do
          assert_raises(RuntimeError) { DRbClientConnectionInfo.new }
        end
      end

      def with_drb(info)
        old_info = Thread.current['DRb']
        begin
          Thread.current['DRb'] = info
          yield
        ensure
          Thread.current['DRb'] = old_info
        end
      end
    end
  end
end
