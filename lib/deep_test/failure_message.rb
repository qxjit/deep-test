module DeepTest
  module FailureMessage
    def self.show(title, message, width = 70)
      lines = [" #{title} ".center(width, '*')]
      message.each do |line|
        lines << "* #{line.strip}".ljust(width - 1) + "*"
      end
      lines <<  "*" * width
      string = lines.join("\n")
      begin
        puts string
      rescue
        IO.new(2) do |err|
          err.puts string
        end
      end
    end
  end
end
