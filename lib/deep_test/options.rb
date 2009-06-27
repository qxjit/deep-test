module DeepTest
  Option = Struct.new :name, :default unless defined?(Option)

  class Options
    unless defined?(VALID_OPTIONS)
      VALID_OPTIONS = [
        Option.new(:distributed_hosts, nil),
        Option.new(:number_of_workers, nil),
        Option.new(:metrics_file,      nil),
        Option.new(:pattern,           nil),
        Option.new(:server_port,       6969),
        Option.new(:sync_options,      {}),
        Option.new(:timeout_in_seconds,30),
        Option.new(:ui,                "DeepTest::UI::Console"),
        Option.new(:worker_listener,   "DeepTest::NullWorkerListener"),
      ]
    end

    attr_accessor *VALID_OPTIONS.map {|o| o.name}

    def number_of_workers
      return CpuInfo.new.count unless @number_of_workers
      @number_of_workers
    end

    def ui=(value)
      @ui = value.to_s
    end

    def worker_listener=(value)
      @worker_listener = value.to_s
    end

    def self.from_command_line(command_line)
      return new({}) if command_line.nil? || command_line.empty?
      Marshal.load Base64.decode64(command_line)
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
      Base64.encode64(Marshal.dump(self)).gsub("\n","")
    end

    def mirror_path(base)
      raise "No source directory specified in sync_options" unless sync_options[:source]
      relative_mirror_path = @origin_hostname + sync_options[:source].gsub('/','_')
      "#{base}/#{relative_mirror_path}"
    end

    def new_deployment
      if distributed_hosts.nil?
        LocalDeployment.new self
      else
        Distributed::RemoteDeployment.new(
          self, 
          Distributed::Server.new_dispatch_controller(self), 
          LocalDeployment.new(self))
      end
    end

    def central_command
      CentralCommand.remote_reference(origin_hostname, server_port)
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
