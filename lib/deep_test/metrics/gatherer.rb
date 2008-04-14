module DeepTest
  module Metrics
    class Gatherer
      def self.setup(options)
        $metrics_gatherer = new(options)

        at_exit do
          $metrics_gatherer.write_file
        end
      end

      def self.enabled?
        return false unless $metrics_gatherer
        $metrics_gatherer.enabled?
      end

      def self.section(title, &block)
        $metrics_gatherer.section(title, &block)
      end

      def initialize(options)
        @options = options
        @sections = []
      end

      def enabled?
        !@options.metrics_file.nil?
      end

      def section(title, &block)
        @sections << Section.new(title, &block) if enabled?
      end

      def render
        @sections.map {|s| s.render}.join("\n")
      end
      
      def write_file
        return unless enabled?
        File.open(@options.metrics_file, "w") do |io|
          io << render
        end
      end

      class Section
        def initialize(title, &generate_measurements_block)
          @title = title
          @generate_measurements_block = generate_measurements_block
        end

        def measurement(name, value)
          @measurements << [name, value]
        end

        def gather_measurements
          @measurements = []
          @generate_measurements_block.call(self)
        end

        def render
          gather_measurements
          "[#{@title}]\n" + @measurements.map {|name, value| "#{name}: #{value}"}.join("\n")
        end
      end
    end
  end
end
