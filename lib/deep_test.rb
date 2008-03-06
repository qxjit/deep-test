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
require 'rubygems'
gem 'rspec'
require 'spec/runner/example_group_runner'
require 'spec/rake/spectask'
require "test/unit/testresult"
require "test/unit/error"
require 'test/unit/failure'

require File.dirname(__FILE__) + "/deep_test/extensions/object_extension"

require File.dirname(__FILE__) + "/deep_test/deadlock_detector"
require File.dirname(__FILE__) + "/deep_test/tuple_space_factory"
require File.dirname(__FILE__) + "/deep_test/rinda_blackboard"
require File.dirname(__FILE__) + "/deep_test/logger"
require File.dirname(__FILE__) + "/deep_test/options"
require File.dirname(__FILE__) + "/deep_test/process_orchestrator"
require File.dirname(__FILE__) + "/deep_test/server"
require File.dirname(__FILE__) + "/deep_test/test_task"

require File.dirname(__FILE__) + "/deep_test/spec"
require File.dirname(__FILE__) + "/deep_test/test"

require File.dirname(__FILE__) + "/deep_test/worker"
require File.dirname(__FILE__) + "/deep_test/warlock"
