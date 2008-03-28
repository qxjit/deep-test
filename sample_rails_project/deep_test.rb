require 'rubygems'
require 'test/unit'
require 'dust'
require 'strscan'

unit_tests do
  test "test:units" do
    assert_successful "rake test:units"
  end

  test "deep_test" do
    assert_successful "rake deep_test"
  end

  test "spec" do
    assert_successful "rake spec"
  end

  test "deep_spec" do
    assert_successful "rake deep_spec"
  end

  def assert_successful(command)
    Dir.chdir(File.dirname(__FILE__)) do |path|
      output = StringScanner.new `#{command} 2>&1`

      failures = []

      while output.scan_until(/Failure:\n.*|.* FAILED/)
        failures << output.matched.gsub(/\n|\e.*m/, " ")
      end
      
      assert $?.success?, "#{command}:\n  #{failures.join("\n  ")}"
    end
  end
end
