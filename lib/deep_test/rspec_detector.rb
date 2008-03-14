module DeepTest
  class RSpecDetector
    def self.if_rspec_available
      require "rubygems"
      # requiring 'spec' directly blows up unit-record
      require "spec/version" 
      yield if defined?(::Spec)
    rescue LoadError, Gem::LoadError
    end
  end
end
