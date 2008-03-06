module DeepTest
  class DeadlockDetector
    def self.due_to_deadlock?(error)
      error && !error.message.to_s.match(/Deadlock found when trying to get lock/).nil?
    end
  end
end
