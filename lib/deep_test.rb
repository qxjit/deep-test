module DeepTest
end
require 'rinda/ring'
require 'rinda/tuplespace'

require "test/unit/testresult"
require "test/unit/error"
require 'test/unit/failure'

require "deep_test/extensions/testresult"
require "deep_test/extensions/error"
require "deep_test/extensions/object_extension"

require "deep_test/tuple_space_factory"
require "deep_test/rinda_blackboard"
require "deep_test/loader"
require "deep_test/server"
require "deep_test/simple_test_blackboard"
require "deep_test/supervised_test_suite"
require "deep_test/supervisor"
require "deep_test/test_task"
require "deep_test/worker"
require "deep_test/warlock"
