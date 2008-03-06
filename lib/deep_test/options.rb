module DeepTest
  class Options
    class Option
      attr_reader :name, :default

      def initialize(name, conversion, default)
        @name, @conversion, @default = name, conversion, default
      end

      def from_command_line(command_line)
        command_line =~ /--#{name} (\S+)(\s|$)/
        $1.send(@conversion)
      end

      def to_command_line(value)
        "--#{name} #{value}" if value
      end
    end

    unless defined?(VALID_OPTIONS)
      VALID_OPTIONS = [
        Option.new(:number_of_workers, :to_i, 2),
        Option.new(:pattern, :to_s, nil),
        Option.new(:timeout_in_seconds, :to_i, 30),
      ]
    end
    attr_accessor *VALID_OPTIONS.map {|o| o.name}

    def self.from_command_line(command_line)
      hash = {}
      VALID_OPTIONS.each do |option|
        hash[option.name] = option.from_command_line(command_line)
      end
      new(hash)
    end

    def initialize(hash)
      check_option_keys(hash)
      VALID_OPTIONS.each do |option|
        send("#{option.name}=", hash[option.name] || option.default)
      end
    end

    def to_command_line
      command_line = []
      VALID_OPTIONS.each do |option|
        command_line << option.to_command_line(send(option.name))
      end
      command_line.compact.join(' ')
    end

    protected

    def check_option_keys(hash)
      hash.keys.each do |key|
        raise InvalidOptionError.new(key) unless VALID_OPTIONS.any? {|o| o.name == key.to_sym}
      end
    end

    class InvalidOptionError < StandardError; end
  end
end
