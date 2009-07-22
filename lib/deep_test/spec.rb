require 'rubygems'
require 'spec/runner/example_group_runner'
if ::Spec::VERSION::MAJOR == 1 &&
   ::Spec::VERSION::MINOR == 1 &&
   ::Spec::VERSION::TINY  >= 12
  require 'spec/example/before_and_after_hooks'
end
require 'spec/example/example_group_methods'
require 'spec/rake/spectask'

require File.dirname(__FILE__) + "/spec/extensions/example_group_methods"
require File.dirname(__FILE__) + "/spec/extensions/example_methods"
require File.dirname(__FILE__) + "/spec/extensions/spec_task"
require File.dirname(__FILE__) + "/spec/extensions/options"
require File.dirname(__FILE__) + "/spec/runner"
require File.dirname(__FILE__) + "/spec/work_unit"
require File.dirname(__FILE__) + "/spec/work_result"
