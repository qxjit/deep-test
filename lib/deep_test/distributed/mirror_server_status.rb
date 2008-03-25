module DeepTest
  module Distributed
    MirrorServerStatus = Struct.new(
      :binding_uri,
      :number_of_workers,
      :remote_worker_server_count
    ) unless defined?(MirrorServerStatus)
  end
end
