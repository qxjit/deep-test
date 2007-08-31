require "rubygems"
begin
  require "daemons"
rescue LoadError
  raise "The daemons gem must be installed"
end

namespace :deep_test do
  namespace :server do
    desc "Starts the server"
    task :start do
      Daemons.run_proc "deep_test_server", :ARGV => ["start"] do
        DeepTest::Server.start
      end
      sleep 0.25
    end
    desc "Stops the server"
    task :stop do
      Daemons.run("deep_test_server", :ARGV => ["stop"])
    end
  end
  
  namespace :workers do
    desc "Starts the workers"
    task :start do
      2.times do
        Daemons.run_proc "deep_test_worker", :multiple => true, :ARGV => ["start"] do
          test_files = ENV['DEEP_TEST_PATTERN']
          Dir.glob(test_files).each { |file| load file }
          blackboard = DeepTest::RindaBlackboard.new
          DeepTest::Worker.new(blackboard).run
        end
        sleep 0.5
      end
    end
    desc "Stops the workers"
    task :stop do
      Daemons.run("deep_test_worker", :ARGV => ["stop"])
    end
  end
end
