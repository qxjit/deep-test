module DeepTest
  class << self
    def logger
      @logger ||= DeepTest::Logger.new($stdout)
    end
  end  
end

require "logger"
require "rinda/ring"
require "rinda/tuplespace"
require "timeout"

require File.dirname(__FILE__) + "/deep_test/extensions/object_extension"

require File.dirname(__FILE__) + "/deep_test/deadlock_detector"
require File.dirname(__FILE__) + "/deep_test/tuple_space_factory"
require File.dirname(__FILE__) + "/deep_test/rinda_blackboard"
require File.dirname(__FILE__) + "/deep_test/logger"
require File.dirname(__FILE__) + "/deep_test/null_worker_listener"
require File.dirname(__FILE__) + "/deep_test/options"
require File.dirname(__FILE__) + "/deep_test/process_orchestrator"
require File.dirname(__FILE__) + "/deep_test/rspec_detector"
require File.dirname(__FILE__) + "/deep_test/server"
require File.dirname(__FILE__) + "/deep_test/test_task"
require File.dirname(__FILE__) + "/deep_test/worker"
require File.dirname(__FILE__) + "/deep_test/warlock"

DeepTest::RSpecDetector.if_rspec_available do
  require File.dirname(__FILE__) + "/deep_test/spec"
end
require File.dirname(__FILE__) + "/deep_test/test"

