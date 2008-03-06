module DeepTest
  class RSpecDetector
    def self.if_rspec_available
      begin
        require 'rubygems'
      rescue LoadError
      else
        begin
          gem 'rspec'
        rescue Gem::LoadError
        else
          yield
        end
      end
    end
  end
end
