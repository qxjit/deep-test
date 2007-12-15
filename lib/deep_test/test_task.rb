module DeepTest
  class TestTask
    attr_writer :pattern, :processes

    def initialize(name = :deep_test)
      @name = name
      yield self if block_given?
      define
    end
    
    def define
      desc "Run '#{@name}' suite using DeepTest"
      task @name do
        begin
          deep_test_lib = File.expand_path(File.dirname(__FILE__) + "/..")
          $LOAD_PATH << deep_test_lib
          require "deep_test"
          warlock = DeepTest::Warlock.new
          
          # server
          warlock.start "server" do
            DeepTest::Server.start
          end
          sleep 0.25          

          # workers
          processes.times do |i|
            warlock.start "worker #{i}" do
              srand # re-seed random numbers
              ENV["RAILS_ENV"] = "test"
              Object.const_set "RAILS_ENV", "test"
              Dir.glob(pattern).each { |file| load file }
              blackboard = DeepTest::RindaBlackboard.new
              DeepTest::Worker.new(blackboard).run
            end
          end

          # loader
          loader = File.expand_path(File.dirname(__FILE__) + "/loader.rb")
          ruby "-I#{deep_test_lib} #{loader} '#{pattern}'"
        ensure
          warlock.stop_all if warlock
        end
      end
    end
    
    def pattern
      Dir.pwd + "/" + (@pattern || "test/**/*_test.rb")
    end
    
    def processes
      @processes ? @processes.to_i : 2
    end
  end
end
