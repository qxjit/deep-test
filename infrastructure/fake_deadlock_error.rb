unless defined?(ActiveRecord::StatementInvalid)
  module ActiveRecord
    class StatementInvalid < StandardError
    end
  end
end

class FakeDeadlockError
  def self.new
    ActiveRecord::StatementInvalid.new("Deadlock found when trying to get lock")
  end
end
