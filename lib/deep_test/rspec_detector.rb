module DeepTest
  class RSpecDetector
    def self.if_rspec_available
      begin
        require 'rubygems'
        gem 'rspec'
        yield
      rescue LoadError, Gem::LoadError
      end
    end
  end
end
