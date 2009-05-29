module DeepTest
  module Distributed
    class ShellEnvironment
      def self.like_login
        login_env = new
        login_env.include_first '/etc/profile'
        login_env.include_first '~/.profile', '~/.bashrc'
        login_env
      end

      def initialize
        @source_file_lists = []
      end

      def include_first(*filenames)
        source_file_lists << SourceFileList.new(filenames)
      end

      def to_s
        source_file_lists.join(" && ")
      end

      def ==(other)
        source_file_lists == other.source_file_lists
      end

      attr_reader :source_file_lists
      protected :source_file_lists

      class SourceFileList
        def initialize(filenames)
          @filenames = filenames
        end

        def to_s
          "if" + 
          filenames.map {|f| " [[ -f #{f} ]]; then . #{f}; "}.join("elif") +
          "fi"
        end

        def ==(other)
          filenames == other.filenames
        end

        attr_reader :filenames
        protected :filenames
      end
    end
  end
end
