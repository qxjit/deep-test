module DeepTest
  class RSpecDetector
    def self.if_rspec_available
      require "rubygems"
      # requiring 'spec' directly blows up unit-record
      require "spec/version"
      if defined?(::Spec)
        if ::Spec::VERSION::MAJOR == 1 &&
           ::Spec::VERSION::MINOR == 1 &&
           ::Spec::VERSION::TINY  >= 8
          yield
        else
          require 'spec/rake/spectask'
          ::Spec::Rake::SpecTask.class_eval do
            def deep_test(options)
              raise "* DeepTest RSpec support requires RSpec 1.1.8"
            end
          end
        end
      end
    rescue LoadError, Gem::LoadError
    end
  end
end
