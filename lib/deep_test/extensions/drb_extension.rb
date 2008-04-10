module DeepTest
  class DRbBindAllTCPSocket < DRb::DRbTCPSocket
    def self.parse_uri(uri)
      if uri =~ /^drubyall:\/\/(.*?):(\d+)(\?(.*))?$/
      	host = $1
      	port = $2.to_i
      	option = $4
      	[host, port, option]
      else
      	raise(DRbBadScheme, uri) unless uri =~ /^drubyall:/
      	raise(DRbBadURI, 'can\'t parse uri:' + uri)
    	end
    end

    # Open a server listening for connections at +uri+ using 
    # configuration +config+.
    def self.open_server(uri, config)
      uri = 'drubyall://:0' unless uri
      host, port, opt = parse_uri(uri)

      if host.size == 0
        host = getservername
      end

      DeepTest.logger.debug("Listening on port #{port}, all addresses.")
	    soc = TCPServer.open('0.0.0.0', port)  	    
      port = soc.addr[1] if port == 0
      uri = "druby://#{host}:#{port}"
      self.new(uri, soc, config)
    end
  end
end

DRb::DRbProtocol.add_protocol DeepTest::DRbBindAllTCPSocket
