require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "returns ipaddress from peeraddr as address" do
    info = Thread.current['DRb']
    begin
      Thread.current['DRb'] = {
        'client' => mock(:peeraddr => [nil, nil, "ip", nil])
      }

      info = DeepTest::Distributed::DRbClientConnectionInfo.new
    ensure
      Thread.current['DRb'] = info
    end

    assert_equal "ip", info.address
  end

  test "raises an error if no drb client is found" do
    info = Thread.current['DRb']
    begin
      Thread.current['DRb'] = {}
      assert_raises(RuntimeError) do
        DeepTest::Distributed::DRbClientConnectionInfo.new
      end
    ensure
      Thread.current['DRb'] = info
    end
  end

  test "raises an error if no drb info is found" do
    info = Thread.current['DRb']
    begin
      Thread.current['DRb'] = nil
      assert_raises(RuntimeError) do
        DeepTest::Distributed::DRbClientConnectionInfo.new
      end
    ensure
      Thread.current['DRb'] = info
    end
  end
end
