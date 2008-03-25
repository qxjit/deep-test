module DeepTest
  module Distributed
    class SSHLogin
      PASSWORD_PROMPT = "Password:" unless defined?(PASSWORD_PROMPT)
      AUTHENTICITY_PROMPT = "Are you sure you want to continue connecting (yes/no)?" unless defined?(AUTHENTICITY_PROMPT)

      def self.login(password, rexpect)
        prompts = [Regexp.quote(PASSWORD_PROMPT),Regexp.quote(AUTHENTICITY_PROMPT)]
        while prompt = rexpect.expect(/#{prompts.join('|')}/, 30)
          case prompt.first
            when PASSWORD_PROMPT
              rexpect.puts password
            when AUTHENTICITY_PROMPT
              rexpect.puts "yes"
          end
        end
      rescue Timeout::Error, EOFError
        nil
      end

      def self.system(password, command)
        RExpect.spawn(command) do |rexpect|  
          login password, rexpect
        end
      rescue Errno::ECHILD
      end
    end
  end
end
