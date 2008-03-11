require File.dirname(__FILE__) + "/../../../spec_helper"

describe Spec::Example::ExampleGroupMethods do
  it_should_behave_like "sandboxed rspec_options"
  it "should raise error on append_before(:all)" do
    lambda {
      Class.new(Spec::Example::ExampleGroup) do
        append_before(:all) {}
      end
    }.should raise_error
  end

  it "should not raise error on append_before(:each)" do
    lambda {
      Class.new(Spec::Example::ExampleGroup) do
        append_before(:each) {}
      end
    }.should_not raise_error
  end

  it "should raise error on before(:all)" do
    lambda {
      Class.new(Spec::Example::ExampleGroup) do
        before(:all) {}
      end
    }.should raise_error
  end

  it "should not raise error on before(:each)" do
    lambda {
      Class.new(Spec::Example::ExampleGroup) do
        before(:each) {}
      end
    }.should_not raise_error
  end

  it "should raise error on prepend_before(:all)" do
    lambda {
      Class.new(Spec::Example::ExampleGroup) do
        prepend_before(:all) {}
      end
    }.should raise_error
  end

  it "should not raise error on prepend_before(:each)" do
    lambda {
      Class.new(Spec::Example::ExampleGroup) do
        prepend_before(:each) {}
      end
    }.should_not raise_error
  end

  it "should raise error on append_after(:all)" do
    lambda {
      Class.new(Spec::Example::ExampleGroup) do
        append_after(:all) {}
      end
    }.should raise_error
  end

  it "should not raise error on append_after(:each)" do
    lambda {
      Class.new(Spec::Example::ExampleGroup) do
        append_after(:each) {}
      end
    }.should_not raise_error
  end

  it "should raise error on after(:all)" do
    lambda {
      Class.new(Spec::Example::ExampleGroup) do
        after(:all) {}
      end
    }.should raise_error
  end

  it "should not raise error on after(:each)" do
    lambda {
      Class.new(Spec::Example::ExampleGroup) do
        after(:each) {}
      end
    }.should_not raise_error
  end

  it "should raise error on prepend_after(:all)" do
    lambda {
      Class.new(Spec::Example::ExampleGroup) do
        prepend_after(:all) {}
      end
    }.should raise_error
  end

  it "should not raise error on prepend_after(:each)" do
    lambda {
      Class.new(Spec::Example::ExampleGroup) do
        prepend_after(:each) {}
      end
    }.should_not raise_error
  end

end
