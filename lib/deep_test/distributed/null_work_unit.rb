module DeepTest
  module Distributed
    #
    # Work Unit used to measure throughput of workers.
    #
    class NullWorkUnit
      def run
        :null_work_unit_result
      end
    end
  end
end
