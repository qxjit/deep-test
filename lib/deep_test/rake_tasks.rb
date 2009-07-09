require "socket"
require "base64"

require File.dirname(__FILE__) + "/options"
require File.dirname(__FILE__) + "/cpu_info"
require File.dirname(__FILE__) + "/test_task"
require File.dirname(__FILE__) + "/rspec_detector"

DeepTest::RSpecDetector.if_rspec_available do
  require 'spec/rake/spectask'
  require File.dirname(__FILE__) + "/spec/extensions/spec_task"
end

