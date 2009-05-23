require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "returns ipaddress from SSH_CLIENT as address" do
    info = nil
    with_env("SSH_CLIENT", "168.0.0.1 33345 22") do
      info = DeepTest::Distributed::SshClientConnectionInfo.new
    end
    assert_equal "168.0.0.1", info.address
  end

  test "raises an error if SSH_CLIENT is blank" do
    with_env("SSH_CLIENT", "") do
      assert_raises(RuntimeError) do
        DeepTest::Distributed::SshClientConnectionInfo.new
      end
    end
  end

  test "raises an error if no SSH_CLIENT is found" do
    with_env("SSH_CLIENT", nil) do
      assert_raises(RuntimeError) do
        DeepTest::Distributed::SshClientConnectionInfo.new
      end
    end
  end

  def with_env(variable, value)
    old_value, ENV[variable] = ENV[variable], value
    yield
  ensure
    ENV[variable] = old_value
  end
end

