require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "number_of_agents is determined by options" do
      deployment = LocalDeployment.new Options.new(:number_of_agents => 4)
      assert_equal 4, deployment.number_of_agents
    end

    test "load_files simply loads each file provided" do
      deployment = LocalDeployment.new Options.new({})

      deployment.expects(:load).with(:file_1)
      deployment.expects(:load).with(:file_2)

      deployment.load_files([:file_1, :file_2])
    end
  end
end
