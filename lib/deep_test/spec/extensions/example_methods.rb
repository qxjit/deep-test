module Spec
  module Example
    module ExampleMethods
      def identifier
        file, line = implementation_backtrace.first.split(/:/)
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
                       file == other.file && 
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
        end

        def to_s
          "#{group_description} #{description}"
        end
      end
    end
  end
end
