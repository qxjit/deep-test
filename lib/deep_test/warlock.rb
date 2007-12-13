module DeepTest
  class Warlock
    def initialize
      @demons = []
    end
    
    def start(name, &block)
      begin
        pid = Process.fork do
          Signal.trap("HUP") { exit 0 }
          yield
          exit
        end
        raise "fatal: fork returned nil" if pid.nil?
        @demons << [name, pid]
        puts "Started #{name} (#{pid})"
      rescue => e
        puts "exception starting #{name}: #{e}"
        puts "\t" + e.backtrace.join("\n\t")
      end
    end

    def stop_all
      @demons.reverse.each do |demon|
        name, pid = demon
        if running?(pid)
          Process.kill("HUP", pid)
        end
      end
      @demons.each do |demon|
        name, pid = demon
        begin
          Process.wait(pid)
        rescue Errno::ECHILD => e
          puts e
        end
        puts "Stopped #{name} (#{pid})"
      end
    end

    #stolen from daemons
    def running?(pid)
      # Check if process is in existence
      # The simplest way to do this is to send signal '0'
      # (which is a single system call) that doesn't actually
      # send a signal
      begin
        Process.kill(0, pid)
        return true
      rescue Errno::ESRCH
        return false
      rescue ::Exception   # for example on EPERM (process exists but does not belong to us)
        return true
      #rescue Errno::EPERM
      #  return false
      end
    end    
  end
end
