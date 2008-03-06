require File.dirname(__FILE__) + "/../../../spec_helper"

describe Spec::Rake::SpecTask do
  it "should allow deep_test configuration" do
    t = Spec::Rake::SpecTask.new do |t|
      t.deep_test :number_of_workers => 2
    end

    deep_test_path = File.expand_path(File.dirname(__FILE__) + 
                                      '/../../../../lib/deep_test')
    options = DeepTest::Options.new(:number_of_workers => 2)
    t.spec_opts.should == ["--require #{deep_test_path}",
                           "--runner 'DeepTest::Spec::Runner:#{options.to_command_line}'"]
  end
end
