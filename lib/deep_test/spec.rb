require 'rubygems'
require 'spec/runner/example_group_runner'
require 'spec/example/example_group_methods'
require 'spec/rake/spectask'

require File.dirname(__FILE__) + "/spec/extensions/example_group_methods"
require File.dirname(__FILE__) + "/spec/extensions/example_methods"
require File.dirname(__FILE__) + "/spec/extensions/spec_task"
require File.dirname(__FILE__) + "/spec/extensions/options"
require File.dirname(__FILE__) + "/spec/extensions/reporter"
require File.dirname(__FILE__) + "/spec/runner"
require File.dirname(__FILE__) + "/spec/work_unit"
require File.dirname(__FILE__) + "/spec/work_result"
