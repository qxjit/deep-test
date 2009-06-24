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

    test "replace_stdout_stderr! yields" do
      yielded = false
      ProxyIO.replace_stdout_stderr!(mock, mock) { yielded = true }
      assert yielded, "didn't yield"
    end

    test "will replace stdout with proxy to target" do
      ProxyIO.replace_stdout_stderr!(new_stdout = mock, mock) do
        new_stdout.expects(:write).with "global string"
        new_stdout.expects(:write).with "const string"
        $stdout.write "global string"
        STDOUT.write "const string"
      end
    end

    test "will restore stdout after yielding" do
      old_stdout_global, old_stdout_const = $stdout, STDOUT
      ProxyIO.replace_stdout_stderr!(mock, mock) { raise "error" } rescue nil
      assert_equal old_stdout_global, $stdout
      assert_equal old_stdout_const, STDOUT
    end

    test "will replace stderr with proxy to target" do
      ProxyIO.replace_stdout_stderr!(mock, new_stderr = mock) do
        new_stderr.expects(:write).with "global string"
        new_stderr.expects(:write).with "const string"
        $stderr.write "global string"
        STDERR.write "const string"
      end
    end

    test "will restore stderr after yielding" do
      old_stderr_global, old_stderr_const = $stderr, STDERR
      ProxyIO.replace_stdout_stderr!(mock, mock) { raise "error" } rescue nil
      assert_equal old_stderr_global, $stderr
      assert_equal old_stderr_const, STDERR
    end

    test "replace_stdout_stderr! prints exceptions to new stdout" do
      new_stdout = StringIO.new
      assert_raises(Exception) do
        ProxyIO.replace_stdout_stderr!(new_stdout, mock) do
          e = Exception.new "my error"
          e.set_backtrace %w[file1:1 file2:2]
          raise e
        end
      end
      assert_equal <<-end_expected, new_stdout.string
Exception: my error
file1:1
file2:2
      end_expected
    end

    test "supress warnings restores verbose" do
      old_verbose = $VERBOSE
      ProxyIO.supress_warnings { raise "error" } rescue nil
      assert_equal old_verbose, $VERBOSE
    end
  end
end
