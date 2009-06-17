require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "should write strings to proxy target" do
      io = ProxyIO.new(target = mock)
      target.expects(:write).with "my_string"
      io.write "my_string"
    end

    test "should call to_s on any received objects" do
      io = ProxyIO.new(target = mock)
      target.expects(:write).with "some value"
      io.write mock(:to_s => "some value")
    end

    test "should clear string buffer after forwarding to target" do
      io = ProxyIO.new(target = mock)
      target.expects(:write).with "string 1"
      target.expects(:write).with "string 2"
      io.write "string 1"
      io.write "string 2"
    end

    test "should forward flush to the target" do
      io = ProxyIO.new(target = mock)
      target.expects(:flush)
      io.flush
    end

    test "replace_stdout! yields" do
      yielded = false
      ProxyIO.replace_stdout!(target = mock) { yielded = true }
      assert yielded, "didn't yield"
    end

    test "will replace stdout with proxy to target" do
      ProxyIO.replace_stdout!(target = mock) do
        target.expects(:write).with "global string"
        target.expects(:write).with "const string"
        $stdout.write "global string"
        STDOUT.write "const string"
      end
    end

    test "will restore stdout after yielding" do
      old_stdout_global, old_stdout_const = $stdout, STDOUT
      ProxyIO.replace_stdout!(mock) { raise "error" } rescue nil
      assert_equal old_stdout_global, $stdout
      assert_equal old_stdout_const, STDOUT
    end

    test "supress warnings restores verbose" do
      old_verbose = $VERBOSE
      ProxyIO.supress_warnings { raise "error" } rescue nil
      assert_equal old_verbose, $VERBOSE
    end
  end
end
