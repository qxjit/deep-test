require "stringio"
module DeepTest
  module ObjectExtension
    def capture_stdout
      old_stdout, $stdout = $stdout, StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = old_stdout if old_stdout
    end
    
    def retrying(description = nil, times = 5)
      i = 0
      loop do
        begin
          return yield
        rescue => e
          i += 1
          print "#{description} received exception #{e}. "
          if i < times
            puts "Retrying..."
            sleep 0.5
          else
            puts "Aborting."
            raise e
          end
        end
      end
    end
  end
end
Object.send :include, DeepTest::ObjectExtension
