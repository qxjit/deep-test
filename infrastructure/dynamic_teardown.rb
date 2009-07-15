module DynamicTeardown
  class <<self
    def setup
      stack.push []
    end

    def stack
      @stack ||= []
    end

    def on_teardown(&block)
      stack.last << block
    end

    def teardown
      teardowns = stack.pop
      while td = teardowns.shift
        td.call rescue nil
      end
    end
  end
end
