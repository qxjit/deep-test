module DynamicTeardown
  class <<self
    def dynamic_teardowns
      @dynamic_teardowns ||= []
    end

    def on_teardown(&block)
      dynamic_teardowns << block
    end

    def run_dynamic_teardowns
      while td = dynamic_teardowns.shift
        td.call rescue nil
      end
    end
  end
end
