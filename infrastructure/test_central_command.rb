module DeepTest
  class TestCentralCommand < CentralCommand
    def self.start(options)
      central_command = super
      DynamicTeardown.on_teardown { central_command.stop }
      central_command
    end

    def remaining_result_count
      @result_queue.size
    end
  end
end
