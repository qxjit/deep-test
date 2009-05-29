require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "count parses sysctl output on darwin" do
      cpu_info = CpuInfo.new("foodarwinbar")
      cpu_info.expects(:`).with("sysctl -n hw.ncpu").returns("2\n")
      assert_equal 2, cpu_info.count
    end

    test "count parses /proc/cpuinfo on linux" do
      cpu_info = CpuInfo.new("foolinuxbar")
      File.expects(:readlines).with("/proc/cpuinfo").returns [
        "processor	: 0",
        "vendor_id	: GenuineIntel",
        "cpu family	: 6",
        "",
        "processor	: 1",
        "vendor_id	: GenuineIntel",
        "cpu family	: 6",
      ]
      assert_equal 2, cpu_info.count
    end

    test "count returns nil on other platforms" do
      assert_equal nil, CpuInfo.new("foobar").count
    end

    test "platform defaults to the current ruby_platform" do
      assert_equal RUBY_PLATFORM, CpuInfo.new.platform
    end
  end
end
