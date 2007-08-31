$LOAD_PATH.unshift File.dirname(__FILE__)
require "deep_test"
task_dir = File.dirname(__FILE__) + "/tasks"
Dir.glob(task_dir + "/**/*.rake").each { |file| load file }
