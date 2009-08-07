module DeepTest
  Option = Struct.new :name, :default unless defined?(Option)

  class Options
    unless defined?(VALID_OPTIONS)
      VALID_OPTIONS = [
        Option.new(:distributed_hosts, nil),
        Option.new(:number_of_agents,  nil),
        Option.new(:metrics_file,      nil),
        Option.new(:pattern,           nil),
        Option.new(:server_port,       nil),
        Option.new(:sync_options,      {}),
        Option.new(:ui,                "DeepTest::UI::Console"),
        Option.new(:listener,          "DeepTest::NullListener"),
      ]
    end

    attr_accessor *VALID_OPTIONS.map {|o| o.name}
    attr_accessor :ssh_client_connection_info, :environment_log_level

    def number_of_agents
      return CpuInfo.new.count unless @number_of_agents
      @number_of_agents
    end

    def ui=(value)
      @ui = value.to_s
    end

    def listener=(value)
      @listener = value.to_s
    end

    def self.from_command_line(command_line)
      return new({}) if command_line.nil? || command_line.empty?
      Marshal.load Base64.decode64(command_line)
    end

    def initialize(hash)
      @origin_hostname = Socket.gethostname
      check_option_keys(hash)
      VALID_OPTIONS.each do |option|
        send("#{option.name}=", hash[option.name] || hash[option.name.to_s] || option.default)
      end
      self.environment_log_level = ENV['DEEP_TEST_LOG_LEVEL']
    end

    def gathering_metrics?
      !@metrics_file.nil?
    end

    def new_listener_list
      listeners = listener.split(',').map do |listener|
        eval(listener).new
      end
      ListenerList.new(listeners)
    end

    def origin_hostname
      (Socket.gethostname == @origin_hostname) ? 'localhost' : @origin_hostname
    end

    def connect_to_central_command
      address = ssh_client_connection_info ? ssh_client_connection_info.address : "localhost"
      Telegraph::Wire.connect(address, server_port) do |wire|
        yield wire
      end
    end

    # Don't store UI instances in the options instance, which will
    # need to be dumped over Telegraph since UI instances may not be dumpable.
    #
    UI_INSTANCES = {} unless defined?(UI_INSTANCES)
    def ui_instance
      UI_INSTANCES[self] ||= eval(ui).new(self)
    end

    def to_command_line
      Base64.encode64(Marshal.dump(self)).gsub("\n","")
    end

    def mirror_path
      raise "No source directory specified in sync_options" unless sync_options[:source]
      relative_mirror_path = @origin_hostname + sync_options[:source].gsub('/','_')
      "#{sync_options[:remote_base_dir] || '/tmp'}/#{relative_mirror_path}"
    end

    def new_deployment
      if distributed_hosts.nil?
        LocalDeployment.new self
      else
        Distributed::RemoteDeployment.new self, new_landing_fleet, LocalDeployment.new(self)
      end
    end

    def new_landing_fleet
      landing_ships = distributed_hosts.map do |host|
        Distributed::LandingShip.new :address => host
      end
      Distributed::LandingFleet.new self, landing_ships
    end

    protected

    def check_option_keys(hash)
      hash.keys.each do |key|
        raise InvalidOptionError.new("#{key} is not a valid option") unless VALID_OPTIONS.any? {|o| o.name == key.to_sym}
      end
    end

    class InvalidOptionError < StandardError; end
  end
end
