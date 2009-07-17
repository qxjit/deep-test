module DeepTest
  class TestOperator < Telegraph::Operator
    def self.listen(options)
      operator = super("localhost", 0, Telegraph::Switchboard.new)
      DynamicTeardown.on_teardown { operator = shutdown }
      options.telegraph_port = operator.port
      operator 
    end

    def next_message
      @switchboard.next_message(:timeout => 0.1)
    end
  end
end

