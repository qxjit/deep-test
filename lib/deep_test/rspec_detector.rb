module DeepTest
  class RSpecDetector
    def self.if_rspec_available
      require "rubygems"
      gem "rspec"
      yield
    rescue LoadError, Gem::LoadError
    end
  end
end
