require 'rubygems'
require 'test/unit'
require 'dust'
require 'timeout'

unit_tests do
  [:test, :spec].each do |framework|
    test "#{framework}: DeepTest a failing test results in failure" do
      result, output = run_rake framework, :failing
      assert_equal false, result.success?, output
    end

    test "#{framework}: Distributed DeepTest with failover to local" do
      result, output = run_rake framework, :failover_to_local
      assert_equal true, result.success?, output
      assert_match /RSync Failed!!/, output
      assert_match /Failing over to local run/, output
    end

    test "#{framework}: Distributed DeepTest with a host down" do
      result, output = run_rake framework, :just_one_with_host_down
      assert_equal true, result.success?, output
      assert_match /RSync Failed!!/, output
      assert_no_match /Failing over to local run/, output
    end

    test "#{framework}: DeepTest with agents that die" do
      result, output = run_rake framework, :with_agents_dying
      assert_equal false, result.success?, output
      assert_match /DeepTest Agents Are Not Running/, output
      assert_match /DeepTest::IncompleteTestRunError.*100 tests were not run because the DeepTest Agents died/m, output
    end
    
    test "#{framework}: DeepTest processes go away after the test run ends" do
      Timeout.timeout(15) { run_rake framework, :passing }
    end
  end

  def run_rake(framework, task)
    command = "rake --rakefile #{File.dirname(__FILE__)}/tasks.rake deep_#{framework}_#{task} 2>&1"
    output = `#{command}`.map {|l| "[rake deep_#{framework}_#{task}] #{l}" }.join
    return $?, output
  end

end
