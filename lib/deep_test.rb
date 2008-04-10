module DeepTest
  class << self
    def logger
      @logger ||= DeepTest::Logger.new($stdout)
    end
  end  

  # Fork in a separate thread.  If we fork from a DRb thread
  #  (a thread handling a method call invoked over drb),
  #  DRb still thinks the current object is the DRb Front Object,
  #  and reports its uri as the same as in the parent process, even
  #  if you restart DRb service.
  #
  def self.drb_safe_fork(&block)
    Thread.new {Process.fork(&block)}.value
  end
end

$LOAD_PATH << File.dirname(__FILE__) + "/inc"

require "logger"
require "drb"
require "timeout"
require "thread"
require "socket"
require "webrick"
require "timeout"

$expect_verbose = false
require "RExpect"
RExpect.logger = Logger.new($stdout)
RExpect.logger.level = Logger::ERROR

require File.dirname(__FILE__) + "/deep_test/extensions/object_extension"
require File.dirname(__FILE__) + "/deep_test/extensions/drb_extension"

require File.dirname(__FILE__) + "/deep_test/deadlock_detector"
require File.dirname(__FILE__) + "/deep_test/local_workers"
require File.dirname(__FILE__) + "/deep_test/logger"

require File.dirname(__FILE__) + "/deep_test/null_worker_listener"
require File.dirname(__FILE__) + "/deep_test/listener_list"
require File.dirname(__FILE__) + "/deep_test/option"
require File.dirname(__FILE__) + "/deep_test/options"
require File.dirname(__FILE__) + "/deep_test/process_orchestrator"
require File.dirname(__FILE__) + "/deep_test/result_reader"
require File.dirname(__FILE__) + "/deep_test/rspec_detector"
require File.dirname(__FILE__) + "/deep_test/server"
require File.dirname(__FILE__) + "/deep_test/test_task"
require File.dirname(__FILE__) + "/deep_test/worker"
require File.dirname(__FILE__) + "/deep_test/warlock"

require File.dirname(__FILE__) + "/deep_test/database/setup_listener"
require File.dirname(__FILE__) + "/deep_test/database/mysql_setup_listener"

require File.dirname(__FILE__) + "/deep_test/distributed/dispatch_controller"
require File.dirname(__FILE__) + "/deep_test/distributed/drb_client_connection_info"
require File.dirname(__FILE__) + "/deep_test/distributed/filename_resolver"
require File.dirname(__FILE__) + "/deep_test/distributed/master_test_server"
require File.dirname(__FILE__) + "/deep_test/distributed/test_server"
require File.dirname(__FILE__) + "/deep_test/distributed/test_server_status"
require File.dirname(__FILE__) + "/deep_test/distributed/test_server_workers"
require File.dirname(__FILE__) + "/deep_test/distributed/multi_test_server_proxy"
require File.dirname(__FILE__) + "/deep_test/distributed/null_work_unit"
require File.dirname(__FILE__) + "/deep_test/distributed/remote_worker_client"
require File.dirname(__FILE__) + "/deep_test/distributed/remote_worker_server"
require File.dirname(__FILE__) + "/deep_test/distributed/rsync"
require File.dirname(__FILE__) + "/deep_test/distributed/ssh_login"
require File.dirname(__FILE__) + "/deep_test/distributed/throughput_runner"
require File.dirname(__FILE__) + "/deep_test/distributed/throughput_statistics"
require File.dirname(__FILE__) + "/deep_test/distributed/throughput_worker_client"

DeepTest::RSpecDetector.if_rspec_available do
  require File.dirname(__FILE__) + "/deep_test/spec"
end
require File.dirname(__FILE__) + "/deep_test/test"

require File.dirname(__FILE__) + "/deep_test/ui/console"
require File.dirname(__FILE__) + "/deep_test/ui/null"
