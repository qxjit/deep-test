require 'rubygems'
require 'test/unit'
require 'dust'

unit_tests do
  test "DeepTest a failing test results in failure" do
    result, output = run_rake :deep_test_failing
    assert_equal false, result.success?, output
  end

  test "Distributed DeepTest with failover to local" do
    result, output = run_rake :deep_test_failover_to_local
    assert_equal true, result.success?, output
    assert_match /RSync Failed!!/, output
    assert_match /Failing over to local run/, output
  end

  test "Distributed DeepTest with a host down" do
    result, output = run_rake :deep_test_with_host_down
    assert_equal true, result.success?, output
    assert_match /RSync Failed!!/, output
    puts "should assert no failover, but need to change beachhead to not depend on rake first"
    #assert_no_match /Failing over to local run/, output
  end

  test "DeepTest with agents that die" do
    result, output = run_rake :deep_test_with_agents_dying
    assert_equal false, result.success?, output
    assert_match /DeepTest Agents Are Not Running/, output
  end
  
  test "DeepTest processes go away after the test run ends" do
    puts "figure out correct setup and assertion here"
    #result, output = run_rake :deep_test_passing
    #assert_equal true, result.success?
    #assert_equal "", `ps | grep ruby | grep -v grep | grep -v #{Process.pid}`
  end

  def run_rake(task)
    command = "rake --rakefile #{File.dirname(__FILE__)}/tasks.rake #{task} 2>&1"
    output = `#{command}`.map {|l| "[rake #{task}] #{l}" }.join
    return $?, output
  end

end
