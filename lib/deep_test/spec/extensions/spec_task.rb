require File.dirname(__FILE__) + "/../../lib_root"

module Spec
  module Rake
    class SpecTask
      def deep_test(options)
        deep_test_options = DeepTest::Options.new(options)
        deep_test_path = File.expand_path(DeepTest::LIB_ROOT + "/deep_test")
        @deep_test_spec_opts = [
          "--require #{deep_test_path}",
          "--runner 'DeepTest::Spec::Runner:#{deep_test_options.to_command_line}'"
        ]
        spec_opts.concat @deep_test_spec_opts
      end

      def spec_opts=(options)
        @spec_opts = (@deep_test_spec_opts || []) + options
      end
    end
  end
end
