module DeepTest
  class TestCentralCommand < CentralCommand
    def self.start(options)
      central_command = super
      DynamicTeardown.on_teardown { central_command.stop }
      central_command
    end
  end
end
