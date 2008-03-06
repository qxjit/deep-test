module Spec
  module Rake
    class SpecTask
      def deep_test(options)
        deep_test_options = DeepTest::Options.new(options)
        deep_test_path = File.expand_path(File.dirname(__FILE__) + 
                                          "/../../../deep_test")
        spec_opts << "--require #{deep_test_path}"
        spec_opts << "--runner 'DeepTest::Spec::Runner:#{deep_test_options.to_command_line}'"
      end
    end
  end
end
