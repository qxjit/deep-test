module DeepTest
  module UI
    class Console
      def initialize(options)
      end

      METHOD_DESCRIPTIONS = {
        :sync => "Synchronizing working copies on worker machines",
        :spawn_worker_server => "Spawning test environment processes",
        :load_files => "Loading test files for workers",
        :start_all => "Starting workers",
        :stop_all => "Stopping workers"
      } unless defined?(METHOD_DESCRIPTIONS)

      def dispatch_starting(method_name)
        @spinner.stop if @spinner
        @spinner = Spinner.new(label(method_name))
        @spinner.start
      end

      def label(method_name)
        METHOD_DESCRIPTIONS[method_name.to_sym] || method_name.to_s
      end

      def dispatch_finished(method_name)
        @spinner.stop if @spinner
        @spinner = nil
      end

      class Spinner
        FRAMES = ['|', '/', '-', '\\'] unless defined?(FRAMES)
        BACKSPACE = "\x08"  unless defined?(BACKSPACE)
        SECONDS_PER_FRAME = 0.5 / 4 unless defined?(SECONDS_PER_FRAME)

        def initialize(label)
          @label = label
        end

        def start
          @start_time = Time.now
          show "#{@label}: "
          @thread = Thread.new do
            index = 0
            loop do
              show FRAMES[index]
              sleep SECONDS_PER_FRAME
              show BACKSPACE
              index = (index + 1) % FRAMES.length
            end
          end 
        end

        def stop
          @stop_time = Time.now
          @thread.kill if @thread
          show BACKSPACE
          show("finished in %.2f seconds\n" % (@stop_time.to_f - @start_time.to_f))
        end

        def show(string)
          $stdout.print string
          $stdout.flush
        end
      end
    end
  end
end
