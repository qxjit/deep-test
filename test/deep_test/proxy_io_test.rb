require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "should write strings to proxy wire" do
      io = ProxyIO.new(ProxyIO::Stdout, wire = mock)
      wire.expects(:send_message).with ProxyIO::Stdout::Output.new("my_string")
      io.write "my_string"
    end

    test "should call to_s on any received objects" do
      io = ProxyIO.new(ProxyIO::Stdout, wire = mock)
      wire.expects(:send_message).with ProxyIO::Stdout::Output.new("some value")
      io.write mock(:to_s => "some value")
    end

    test "should clear string buffer after forwarding to wire" do
      io = ProxyIO.new(ProxyIO::Stdout, wire = mock)
      wire.expects(:send_message).with ProxyIO::Stdout::Output.new("string 1")
      wire.expects(:send_message).with ProxyIO::Stdout::Output.new("string 2")
      io.write "string 1"
      io.write "string 2"
    end

    test "should forward flush to the wire" do
      io = ProxyIO.new(ProxyIO::Stdout, wire = mock)
      wire.expects(:send_message).with kind_of(ProxyIO::Stdout::Flush)
      io.flush
    end

    test "Stdout::Output prints to stdout" do
      output = ProxyIO::Stdout::Output.new("output")
      assert_equal "output", capture_stdout { output.execute }
    end

    test "Stderr::Output prints to stdout" do
      output = ProxyIO::Stderr::Output.new("output")
      assert_equal "output", capture_stderr { output.execute }
    end

    test "Stdout::Flush prints to stdout" do
      output = ProxyIO::Stdout::Flush.new
      $stdout.expects :flush
      output.execute
    end

    test "Stderr::Flush prints to stdout" do
      output = ProxyIO::Stderr::Flush.new
      $stderr.expects :flush
      output.execute
    end

    test "replace_stdout_stderr! yields" do
      yielded = false
      ProxyIO.replace_stdout_stderr!(mock) { yielded = true }
      assert yielded, "didn't yield"
    end

    test "will replace stdout with proxy to wire" do
      ProxyIO.replace_stdout_stderr!(wire = mock) do
        wire.expects(:send_message).with ProxyIO::Stdout::Output.new("global string")
        wire.expects(:send_message).with ProxyIO::Stdout::Output.new("const string")
        $stdout.write "global string"
        STDOUT.write "const string"
      end
    end

    test "will restore stdout after yielding" do
      old_stdout_global, old_stdout_const = $stdout, STDOUT
      ProxyIO.replace_stdout_stderr!(mock) { raise "error" } rescue nil
      assert_equal old_stdout_global, $stdout
      assert_equal old_stdout_const, STDOUT
    end

    test "will replace stderr with proxy to wire" do
      ProxyIO.replace_stdout_stderr!(wire = mock) do
        wire.expects(:send_message).with ProxyIO::Stderr::Output.new("global string")
        wire.expects(:send_message).with ProxyIO::Stderr::Output.new("const string")
        $stderr.write "global string"
        STDERR.write "const string"
      end
    end

    test "will restore stderr after yielding" do
      old_stderr_global, old_stderr_const = $stderr, STDERR
      ProxyIO.replace_stdout_stderr!(mock) { raise "error" } rescue nil
      assert_equal old_stderr_global, $stderr
      assert_equal old_stderr_const, STDERR
    end

    test "reconnect the logger to the new stdout" do
      old_stderr_global, old_stderr_const = $stderr, STDERR
      ProxyIO.replace_stdout_stderr!(mock) do 
        assert_equal $stdout, DeepTest.logger.io_stream
      end
    end

    test "supress warnings restores verbose" do
      old_verbose = $VERBOSE
      ProxyIO.supress_warnings { raise "error" } rescue nil
      assert_equal old_verbose, $VERBOSE
    end
  end
end
