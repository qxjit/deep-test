module DeepTest
  class Option
    attr_reader :name, :default

    def initialize(name, type, default)
      @name, @type, @default = name, type, default
    end

    def from_command_line(command_line)
      command_line =~ /--#{name} (\S+)(\s|$)/
      @type.from_string($1) if $1
    end

    def to_command_line(value)
      "--#{name} #{@type.to_string(value)}" if value && value != default
    end

    module Hash
      def self.to_string(hash)
        pairs = []
        hash.each do |key, value|
          value = value.gsub(/ /,'%20') if (::String === value)
          pairs << "#{key}:#{value.inspect}"
        end
        pairs.join(",")
      end

      def self.from_string(string)
        hash = {}
        string.split(/,/).each do |pair|
          key, unevaled_value = pair.split(/:/)
          value = eval(unevaled_value)
          value = value.gsub(/%20/, " ") if ::String === value
          hash[key.to_sym] = value
        end
        hash
      end
    end

    module Integer
      def self.to_string(i)
        i.to_s
      end

      def self.from_string(s)
        s.to_i
      end
    end

    module String
      def self.to_string(s)
        s
      end

      def self.from_string(s)
        s
      end
    end
  end
end
