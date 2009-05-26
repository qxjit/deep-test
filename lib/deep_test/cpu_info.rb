module DeepTest
  class CpuInfo
    attr_accessor :platform

    def initialize(platform = RUBY_PLATFORM)
      @platform = platform
    end

    def count
      case platform
      when /darwin/
        output = `sysctl -n hw.ncpu`
        output.strip.to_i
      when /linux/
        File.readlines("/proc/cpuinfo").inject(0) do |count, line|
          next count + 1 if line =~ /processor\s*:\s*\d+/
          count
        end
      end
    end
  end
end
