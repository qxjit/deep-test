require File.dirname(__FILE__) + "/test_task"
Dir.glob(File.dirname(__FILE__) + "/tasks/**/*.rake").each { |file| load file }
