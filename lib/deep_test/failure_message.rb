module DeepTest
  module FailureMessage
    def self.show(title, message, width = 70)
      puts " #{title} ".center(width, '*')
      message.each do |line|
        puts "* #{line.strip}".ljust(width - 1) + "*"
      end
      puts "*" * width
    end
  end
end
