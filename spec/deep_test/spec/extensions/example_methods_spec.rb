require File.dirname(__FILE__) + "/../../../spec_helper"

module Spec
  module Example
    describe ExampleMethods do
      it_should_behave_like "sandboxed rspec_options"

      it "should have identifier that can locate the example by line" do
        group = describe("test") do
          it("example") {}
          it("example") {}
        end

        example_1 = group.examples.first
        example_2 = group.examples.last

        example_1.identifier.locate([group]).should == example_1
        example_2.identifier.locate([group]).should == example_2
      end

      it "should have identifier that can locate the example by name" do
        group = describe("test") do
          2.times do |i|
            it("example#{i}") {}
          end
        end

        example_1 = group.examples.first
        example_2 = group.examples.last

        example_1.identifier.locate([group]).should == example_1
        example_2.identifier.locate([group]).should == example_2
      end

      describe ExampleMethods::Identifier do
        it "should use descriptions in to_s" do
          group = describe("test") do
            it("example") {}
          end

          group.examples.first.identifier.to_s.should == "test example"
        end

        it "should be equal if basenames of paths are equal" do
          id1 = ExampleMethods::Identifier.new("/a/spec.rb",
                                               10,
                                               "group description",
                                               "description")
                                               
          id2 = ExampleMethods::Identifier.new("/b/spec.rb",
                                               10,
                                               "group description",
                                               "description")

          id1.should == id2
        end
      end
    end
  end
end

