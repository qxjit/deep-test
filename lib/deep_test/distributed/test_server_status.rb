module DeepTest
  module Distributed
    TestServerStatus = Struct.new(
      :binding_uri,
      :number_of_workers,
      :remote_worker_server_count
    ) unless defined?(TestServerStatus)
  end
end
