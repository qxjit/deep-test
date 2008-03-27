module DeepTest
  class Warlock
    def initialize
      @demons_semaphore = Mutex.new
      @demons = []
      @reapers = []
    end

    def start(name, &block)
      # Not synchronizing for the fork seems to cause
      # random errors (Bus Error, Segfault, and GC non-object)
      # in RemoteWorkerServer processes.
      #
      begin
        pid = nil
        @demons_semaphore.synchronize do 
          pid = DeepTest.drb_safe_fork do
            # Fork leaves the semaphore locked and we'll never make it
            # to end of synchronize block
            #
            @demons_semaphore.unlock

            begin
              yield
            rescue Exception => e
              DeepTest.logger.debug "Exception in #{name} (#{Process.pid}): #{e.message}"
              raise
            end

            exit
          end

          raise "fatal: fork returned nil" if pid.nil?
          add_demon name, pid
        end

        launch_reaper_thread name, pid

      rescue => e
        puts "exception starting #{name}: #{e}"
        puts "\t" + e.backtrace.join("\n\t")
      end
    end

    def demon_count
      @demons_semaphore.synchronize do
        @demons.size
      end
    end

    def stop_all
      DeepTest.logger.debug("stopping all demons")
      receivers = @demons_semaphore.synchronize do
        @demons.reverse
      end

      receivers.reverse.each do |demon|
        name, pid = demon
        if running?(pid)
          DeepTest.logger.debug("Sending SIGKILL to #{name}, #{pid}")
          Process.kill("KILL", pid)
        end
      end

      DeepTest.logger.debug("waiting for reapers")
      @reapers.each {|r| r.join}
    end

    def exit_when_none_running
      Thread.new do
        loop do
          Thread.pass
          exit(0) unless any_running?
          sleep(0.01)
        end
      end
    end

    def any_running?
      @demons_semaphore.synchronize do
        @demons.any? {|name, pid| running?(pid)}
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

    protected

    def add_demon(name, pid)
      DeepTest.logger.debug "Started: #{name} (#{pid})"
      @demons << [name, pid]
    end

    def remove_demon(name, pid)
      @demons.delete [name, pid]
      DeepTest.logger.debug "Stopped: #{name} (#{pid})"
    end


    def launch_reaper_thread(name, pid)
      @reapers << Thread.new do
        Process.detach(pid).join
        DeepTest.logger.debug("#{name} (#{pid}) reaped")
        @demons_semaphore.synchronize do
          remove_demon name, pid
        end
      end
    end
  end
end
