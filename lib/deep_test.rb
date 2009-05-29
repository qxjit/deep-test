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

  def self.init(options)
    return if @initialized
    @initialized = true
    Metrics::Gatherer.setup(options)
  end

  class WorkUnitNeverReceivedError < StandardError
    def initialize
      super "DeepTest result never received.  Maybe an error was printed above?"
    end

    def backtrace
      []
    end
  end
end

require "logger"
require "drb"
require "timeout"
require "thread"
require "socket"
require "webrick"
require "timeout"
require "base64"

require File.dirname(__FILE__) + "/deep_test/extensions/object_extension"
require File.dirname(__FILE__) + "/deep_test/extensions/drb_extension"

require File.dirname(__FILE__) + "/deep_test/deadlock_detector"
require File.dirname(__FILE__) + "/deep_test/local_workers"
require File.dirname(__FILE__) + "/deep_test/logger"

require File.dirname(__FILE__) + "/deep_test/marshallable_exception_wrapper"
require File.dirname(__FILE__) + "/deep_test/null_worker_listener"
require File.dirname(__FILE__) + "/deep_test/listener_list"
require File.dirname(__FILE__) + "/deep_test/cpu_info"
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

require File.dirname(__FILE__) + "/deep_test/distributed/shell_environment"
require File.dirname(__FILE__) + "/deep_test/distributed/ad_hoc_server"
require File.dirname(__FILE__) + "/deep_test/distributed/dispatch_controller"
require File.dirname(__FILE__) + "/deep_test/distributed/drb_client_connection_info"
require File.dirname(__FILE__) + "/deep_test/distributed/ssh_client_connection_info"
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
require File.dirname(__FILE__) + "/deep_test/distributed/throughput_runner"
require File.dirname(__FILE__) + "/deep_test/distributed/throughput_statistics"
require File.dirname(__FILE__) + "/deep_test/distributed/throughput_worker_client"

require File.dirname(__FILE__) + "/deep_test/metrics/gatherer"

DeepTest::RSpecDetector.if_rspec_available do
  require File.dirname(__FILE__) + "/deep_test/spec"
end
require File.dirname(__FILE__) + "/deep_test/test"

require File.dirname(__FILE__) + "/deep_test/ui/console"
require File.dirname(__FILE__) + "/deep_test/ui/null"
