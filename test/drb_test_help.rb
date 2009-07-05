require 'weakref'

module DRbTestHelp
  # using drbunix prevents a getaddrinfo on our host, which can take 5 seconds
  def drb_server_for(server)
    drb_server = DRb::DRbServer.new "druby://localhost:0", WeakRef.new(server)

    if block_given?
      begin
        yield DRbObject.new_with_uri(drb_server.uri)
      ensure
        drb_server.stop_service
      end
    else
      ObjectSpace.define_finalizer server, proc { drb_server.stop_service }
      return DRbObject.new_with_uri(drb_server.uri)
    end
  end
end
