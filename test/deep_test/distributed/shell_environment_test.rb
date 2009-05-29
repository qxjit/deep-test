require File.dirname(__FILE__) + "/../../test_helper"

module DeepTest
  module Distributed
    unit_tests do
      test "like_login creates enviroment that will behave like login shell" do
        expected_env = ShellEnvironment.new
        expected_env.include_first '/etc/profile'
        expected_env.include_first '~/.profile', '~/.bashrc'

        assert_equal expected_env, ShellEnvironment.like_login
      end

      test "include_first command loads the specified file when it exists" do
        environment = ShellEnvironment.new
        environment.include_first fixture_path('set_foo_to_bar')

        assert_enviroment({:FOO => "bar"}, environment)
      end

      test "include_first does not load the file if it doesnt exist" do
        environment = ShellEnvironment.new
        environment.include_first fixture_path('nonexistent')
        assert_enviroment({:SHELL => ENV['SHELL']}, environment)
      end

      test "include_first loads second file if first does not exist" do
        environment = ShellEnvironment.new

        environment.include_first fixture_path('nonexistent'),
                                  fixture_path('set_foo_to_bar')

        assert_enviroment({:FOO => "bar"}, environment)
      end

      test "include_first does not load second file if first exists" do
        environment = ShellEnvironment.new

        environment.include_first fixture_path('set_foo_to_bar'),
                                  fixture_path('set_foo_to_baz')
      
        assert_enviroment({:FOO => "bar"}, environment)
      end

      test "include_first loads each file when called two separate times" do
        environment = DeepTest::Distributed::ShellEnvironment.new
        environment.include_first fixture_path('set_foo_to_bar')
        environment.include_first fixture_path('set_bar_to_foo')

        assert_enviroment({:FOO => "bar", :BAR => "foo"}, environment)
      end

      test "include_first loads files in order in which it was called" do
        environment = ShellEnvironment.new
        environment.include_first fixture_path('set_foo_to_bar')
        environment.include_first fixture_path('set_foo_to_baz')

        assert_enviroment({:FOO => "baz"}, environment)
      end

      test "source file lists are equal when they will load the same files" do
        assert_equal ShellEnvironment::SourceFileList.new(['a','b']),
                     ShellEnvironment::SourceFileList.new(['a','b'])

        assert_not_equal ShellEnvironment::SourceFileList.new(['a','b']),
                         ShellEnvironment::SourceFileList.new(['b','a'])
      end

      test "environments are equal when files will load in the same order" do
        env1, env2 = ShellEnvironment.new, ShellEnvironment.new

        env1.include_first 'A'; env2.include_first 'A'
        env1.include_first 'B'; env2.include_first 'B'

        assert_equal env1, env2
      end

      test "environments are not equal when files will load in the different order" do
        env1, env2 = ShellEnvironment.new, ShellEnvironment.new

        env1.include_first 'A'; env2.include_first 'B'
        env1.include_first 'B'; env2.include_first 'A'

        assert_not_equal env1, env2
      end

      def assert_enviroment(expected_hash, environment)
        output = `#{environment} && env`
        assert $?.success?, "'#{environment} && env' command failed"

        actual_hash = output.inject({}) do |h, line|
          if line =~ /^(.*?)=(.*)/ && expected_hash.key?($1.to_sym)
            h[$1.to_sym] = $2
          end
          h
        end

        assert_equal expected_hash, actual_hash
      end

      def fixture_path(filename)
        File.expand_path(File.join(File.dirname(__FILE__), 
                                   'shell_environment_fixtures', 
                                   filename))
      end
    end
  end
end
