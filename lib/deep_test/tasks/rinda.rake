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
      Daemons.run_proc "deep_test_server", :ARGV => ["start"], :backtrace => true, :log_output => true do
        require "deep_test"
        ENV["RAILS_ENV"] = "test"
        Object.const_set "RAILS_ENV", "test"
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
      raise "deprecated -dan"
    end
    
    desc "Stops the workers"
    task :stop do
      Daemons.run("deep_test_worker", :ARGV => ["stop"])
    end
  end
end
