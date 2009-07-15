module DRbTestHelp
  def drb_server_for(server)
    drb_server = DRb::DRbServer.new "druby://localhost:0", server

    if block_given?
      begin
        yield DRbObject.new_with_uri(drb_server.uri)
      ensure
        drb_server.stop_service
      end
    else
      DynamicTeardown.on_teardown do
        drb_server.stop_service
      end
      return DRbObject.new_with_uri(drb_server.uri)
    end
  end
end
