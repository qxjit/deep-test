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
      output = `#{command} 2>&1`
      output.gsub!(/^/,"  | ")
      flunk "'#{command}' failed with following output:\n#{output}" unless $?.success?
    end
  end
end
