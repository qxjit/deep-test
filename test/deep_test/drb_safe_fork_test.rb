require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    include DRbTestHelp

    test "should not multiplex responses to multiple clients if fork happens from within a drb call" do
      with_drb_server_for stub(:foo => "foo", :bar => "bar") do |drb_object|
        innie, outie = IO.pipe

        pid = DeepTest.drb_safe_fork do
          with_drb_server_for RemoteObjectThatForksWithOpenConnections.new(drb_object) do |fork_object|
            innie.close
            outie.puts Marshal.dump(fork_object)
            outie.close
            DRb.thread.join
          end
        end

        begin
          Process.detach pid

          outie.close
          fork_reference = Marshal.load(innie.read)
          innie.close

          fork_reference.assert_children_have_independent_streams
        ensure
          Process.kill "TERM", pid
        end
      end
    end

    class RemoteObjectThatForksWithOpenConnections
      include ::Test::Unit::Assertions

      def initialize(server)
        @server = server
      end

      def assert_children_have_independent_streams
        # prime connections
        @server.foo

        2.times do
          DeepTest.drb_safe_fork do
            begin
              100.times do
                assert_equal "foo", @server.foo
                assert_equal "bar", @server.bar
              end
            ensure
              exit!($!.nil? ? 0 : 1)
            end
          end
        end

        Process.waitall.each do |pid, status|
          assert status.success?, "Child pid #{pid} exited with failure"
        end
      end
    end
  end
end
