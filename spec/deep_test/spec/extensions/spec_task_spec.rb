require File.dirname(__FILE__) + "/../../../spec_helper"

describe Spec::Rake::SpecTask do
  it "should allow deep_test configuration" do
    t = Spec::Rake::SpecTask.new do |t|
      t.deep_test :number_of_agents => 2
    end

    deep_test_path = File.expand_path(DeepTest::LIB_ROOT + "/deep_test")
    options = DeepTest::Options.new(:number_of_agents => 2)
    t.spec_opts.should == ["--require #{deep_test_path}",
                           "--runner 'DeepTest::Spec::Runner:#{options.to_command_line}'"]
  end

  it "should maintain deep_test options if spec_opts is set directly" do
    t = Spec::Rake::SpecTask.new do |t|
      t.deep_test({})
      t.spec_opts = ["anoption"]
    end

    deep_test_path = File.expand_path(DeepTest::LIB_ROOT + "/deep_test")
    options = DeepTest::Options.new({})
    t.spec_opts.should == ["--require #{deep_test_path}",
                           "--runner 'DeepTest::Spec::Runner:#{options.to_command_line}'",
                           "anoption"]
  end

  it "should allow spec_opts to be set without deep_test" do
    t = Spec::Rake::SpecTask.new do |t|
      t.spec_opts = ["anoption"]
    end
    t.spec_opts.should == ["anoption"]
  end
end
