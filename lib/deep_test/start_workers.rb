module DeepTest
  module StartWorkers
    def self.run(args)
      processes, pattern = args
      processes.to_i.times do
        Daemons.run_proc "deep_test_worker", :multiple => true, :ARGV => ["start"], :backtrace => true, :log_output => true do
          require "deep_test"
          ENV["RAILS_ENV"] = "test"
          Object.const_set "RAILS_ENV", "test"
          Dir.glob(pattern).each { |file| load file }
          blackboard = DeepTest::RindaBlackboard.new
          DeepTest::Worker.new(blackboard).run
        end
      end
    end
  end
end

if __FILE__ == $0
  require "rubygems"
  require "daemons"
  DeepTest::StartWorkers.run ARGV
end