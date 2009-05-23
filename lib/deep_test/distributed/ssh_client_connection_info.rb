module DeepTest
  module Distributed
    class SshClientConnectionInfo
      attr_reader :address

      def initialize
        raise "SSH_CLIENT environment variable not set" unless ENV['SSH_CLIENT']
        ENV['SSH_CLIENT'] =~ /^(.+) \d+ \d+$/
        raise "Unable to extract address from SSH_CLIENT (#{ENV['SSH_CLIENT']})" unless $1
        @address = $1
      end
    end
  end
end
