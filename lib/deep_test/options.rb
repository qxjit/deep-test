module DeepTest
  class Options
    unless defined?(VALID_OPTIONS)
      VALID_OPTIONS = [
        Option.new(:distributed_server,      Option::String, nil),
        Option.new(:adhoc_distributed_hosts, Option::String, nil),
        Option.new(:number_of_workers,       Option::Integer, 2),
        Option.new(:metrics_file,            Option::String, nil),
        Option.new(:pattern,                 Option::String, nil),
        Option.new(:server_port,             Option::Integer, 6969),
        Option.new(:sync_options,            Option::Hash, {}),
        Option.new(:timeout_in_seconds,      Option::Integer, 30),
        Option.new(:ui,                      Option::String, "DeepTest::UI::Console"),
        Option.new(:worker_listener,         Option::String, "DeepTest::NullWorkerListener"),
      ]
    end

    attr_accessor *VALID_OPTIONS.map {|o| o.name}

    def ui=(value)
      @ui = value.to_s
    end

    def worker_listener=(value)
      @worker_listener = value.to_s
    end

    def self.from_command_line(command_line)
      hash = {}
      VALID_OPTIONS.each do |option|
        hash[option.name] = option.from_command_line(command_line)
      end
      new(hash)
    end

    def initialize(hash)
      @origin_hostname = Socket.gethostname
      check_option_keys(hash)
      VALID_OPTIONS.each do |option|
        send("#{option.name}=", hash[option.name] || option.default)
      end
    end

    def gathering_metrics?
      !@metrics_file.nil?
    end

    def new_listener_list
      listeners = worker_listener.split(',').map do |listener|
        eval(listener).new
      end
      ListenerList.new(listeners)
    end

    def origin_hostname
      (Socket.gethostname == @origin_hostname) ? 'localhost' : @origin_hostname
    end

    # Don't store UI instances in the options instance, which will
    # need to be dumped over DRb.  UI instances may not be dumpable
    # and we don't want to have to start yet another DRb Server
    #
    UI_INSTANCES = {} unless defined?(UI_INSTANCES)
    def ui_instance
      UI_INSTANCES[self] ||= eval(ui).new(self)
    end

    def to_command_line
      command_line = []
      VALID_OPTIONS.each do |option|
        value = send(option.name)
        command_line << option.to_command_line(value)
      end
      command_line.compact.join(' ')
    end

    def mirror_path(base)
      raise "No source directory specified in sync_options" unless sync_options[:source]
      relative_mirror_path = @origin_hostname + sync_options[:source].gsub('/','_')
      "#{base}/#{relative_mirror_path}"
    end

    def new_workers
      if distributed_server.nil? && adhoc_distributed_hosts.nil?
        LocalWorkers.new self
      else
        begin
          Distributed::RemoteWorkerClient.new(self, 
                                              distributed_server_object, 
                                              LocalWorkers.new(self))
        rescue => e
          ui_instance.distributed_failover_to_local("connect", e)
          LocalWorkers.new self
        end
      end
    end

    def distributed_server_object
      return Distributed::TestServer.connect(self) unless distributed_server.nil?
      return Distributed::AdHocServer.new_dispatch_controller(self) unless adhoc_distributed_hosts.nil?
    end

    def server
      Server.remote_reference(origin_hostname, server_port)
    end

    protected

    def check_option_keys(hash)
      hash.keys.each do |key|
        raise InvalidOptionError.new(key) unless VALID_OPTIONS.any? {|o| o.name == key.to_sym}
      end
    end

    class InvalidOptionError < StandardError; end
  end
end
