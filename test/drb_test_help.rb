module DRbTestHelp
  # using drbunix prevents a getaddrinfo on our host, which can take 5 seconds
  def with_drb_server_for(server)
    drb_server = DRb::DRbServer.new "druby://localhost:0", server

    begin
      yield DRbObject.new_with_uri(drb_server.uri)
    ensure
      drb_server.stop_service
    end
  end
end
