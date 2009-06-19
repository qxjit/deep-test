module Spec
  module Example
    module ExampleMethods
      def identifier
        if ::Spec::VERSION::MAJOR == 1 &&
           ::Spec::VERSION::MINOR == 1 &&
           ::Spec::VERSION::TINY  >= 12
          file, line = eval("caller", @_implementation).first.split(/:/)
        else
          file, line = implementation_backtrace.first.split(/:/)
        end
        Identifier.new(file, line.to_i, self.class.description, description)
      end

      class Identifier
        attr_reader :file, :line, :group_description, :description
        def initialize(file, line, group_description, description)
          @file, @line, @group_description, @description = 
           file,  line,  group_description,  description
        end

        def ==(other)
          eql?(other)
        end

        def eql?(other)
          File.basename(file) == File.basename(other.file) && 
                         line == other.line &&
            group_description == other.group_description &&
                  description == other.description
        end

        def hash
          description.hash
        end

        def locate(groups)
          groups.each do |group|
            group.examples.each do |example|
              return example if example.identifier == self
            end
          end
          raise "Unable to locate example #{self}"
        end

        def to_s
          "#{group_description} #{description}"
        end
      end
    end
  end
end
