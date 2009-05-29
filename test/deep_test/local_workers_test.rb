require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    test "number_of_workers is determined by options" do
      workers = LocalWorkers.new(
        Options.new(:number_of_workers => 4)
      )

      assert_equal 4, workers.number_of_workers
    end

    test "load_files simply loads each file provided" do
      workers = LocalWorkers.new(
        Options.new(:number_of_workers => 4)
      )

      workers.expects(:load).with(:file_1)
      workers.expects(:load).with(:file_2)

      workers.load_files([:file_1, :file_2])
    end
  end
end
