module DRbTestHelp
  def drb_server_for(server)

    if block_given?

      begin
        drb_server = DRb::DRbServer.new "druby://localhost:0", server
        yield DRbObject.new_with_uri(drb_server.uri)
      ensure
        drb_server.stop_service if drb_server
        drb_server.thread.join
        DRb.primary_server = nil if DRb.primary_server == drb_server
      end

    else

      begin
        drb_server = DRb::DRbServer.new "druby://localhost:0", server
      ensure
        DynamicTeardown.on_teardown do 
          drb_server.stop_service if drb_server
          drb_server.thread.join
          DRb.primary_server = nil if DRb.primary_server == drb_server
        end
      end

      return DRbObject.new_with_uri(drb_server.uri)
    end
  end
end
