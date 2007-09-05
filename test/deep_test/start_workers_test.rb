require File.dirname(__FILE__) + '/../test_helper'
require "deep_test/start_workers"

unit_tests do
  test "can specify number of processes to start" do
    Daemons.expects(:run_proc).times(3)
    DeepTest::StartWorkers.run [3, "pattern"]
  end
end