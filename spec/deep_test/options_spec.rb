require File.dirname(__FILE__) + "/../spec_helper"

module DeepTest
  describe Options do
    it "should support number_of_workers" do
      Options.new(:number_of_workers => 3).number_of_workers.should == 3
    end

    it "should have reasonable defaults" do
      options = Options.new({})
      options.number_of_workers.should == 2
      options.timeout_in_seconds.should == 30
      options.server_port.should == 6969
      options.pattern.should == nil
      options.metrics_file.should == nil
    end

    it "should support timeout_in_seconds" do
      Options.new(:timeout_in_seconds => 2).timeout_in_seconds.should == 2
    end

    it "should support pattern" do
      Options.new(:pattern => '*').pattern.should == '*'
    end

    it "should support distributed_server" do
      Options.new(:distributed_server => "uri").distributed_server.should == "uri"
    end

    it "should support server_port" do
      Options.new(:server_port => 10).server_port.should == 10
    end

    it "should support sync_options" do
      Options.new(:sync_options => {:options => 1}).sync_options.should == {:options => 1}
    end

    it "should support worker_listener" do
      Options.new(:worker_listener => "AListener").
        worker_listener.should == "AListener"
    end

    it "should use DeepTest::NullWorkerListener as the default listener" do
      Options.new({}).worker_listener.should == "DeepTest::NullWorkerListener"
    end
    
    it "should allow worker_listener to be set with class" do
      class FakeListener; end
      Options.new(:worker_listener => FakeListener).
        worker_listener.should == "DeepTest::FakeListener"
    end

    it "should allow multiple workers to be specified" do
      class FakeListener1; end
      class FakeListener2; end
      options = Options.new(
        :worker_listener => "DeepTest::FakeListener1,DeepTest::FakeListener2"
      )
      listener = options.new_listener_list
      listener.should be_instance_of(DeepTest::ListenerList)
      listener.listeners.should have(2).listeners
      listener.listeners.first.should be_instance_of(FakeListener1)
      listener.listeners.last.should be_instance_of(FakeListener2)
    end

    it "should create a list of worker listeners upon request" do
      Options.new({}).new_listener_list.should be_instance_of(DeepTest::ListenerList)
    end

    it "should support ui" do
      Options.new(:ui => "AUI").ui.should == "AUI"
    end

    it "should use DeepTest:UIas the default listener" do
      Options.new({}).ui.should == "DeepTest::UI::Console"
    end
    
    it "should allow ui to be set with class" do
      class FakeUI; end
      Options.new(:ui => FakeUI).ui.should == "DeepTest::FakeUI"
    end

    it "should instantiate ui, passing itself as parameter" do
      options = Options.new({})
      DeepTest::UI::Console.should_receive(:new).with(options)
      options.ui_instance
    end

    it "should instantiate ui only one" do
      options = Options.new({})
      options.ui_instance.should equal(options.ui_instance)
    end

    it "should support strings as well as symbols" do
      Options.new("number_of_workers" => 2).number_of_workers.should == 2
    end

    it "should raise error when invalid option is specifed" do
      lambda {
        Options.new(:foo => 1)
      }.should raise_error(Options::InvalidOptionError)
    end

    it "should convert to command line option string" do
      options = Options.new(:number_of_workers => 1, :timeout_in_seconds => 3)
      options.to_command_line.should == 
        "--number_of_workers 1 --timeout_in_seconds 3"
    end

    it "should parse from command line option string" do
      options = Options.from_command_line( 
        "--number_of_workers 2 --timeout_in_seconds 3 --pattern *")
      options.number_of_workers.should == 2
      options.timeout_in_seconds.should == 3
      options.pattern.should == '*'
    end

    it "should use default option value when no command line option is present" do
      options = Options.from_command_line("")
      options.number_of_workers.should == 2
    end

    it "should create local workers by default" do
      options = Options.new({})
      options.new_workers.should be_instance_of(LocalWorkers) 
    end

    it "should create remote worker client when distributed server is specified" do
      options = Options.new(:distributed_server => "uri", :sync_options => {:source => "root"})
      Distributed::TestServer.should_receive(:connect).with(options).and_return(:server_instance)
      Distributed::RemoteWorkerClient.should_receive(:new).with(options, :server_instance, be_instance_of(LocalWorkers))
      options.new_workers
    end

    it "should create local workers when connect fails" do
      options = Options.new(:distributed_server => "uri", :sync_options => {:source => "root"}, :ui => "DeepTest::UI::Null")
      Distributed::TestServer.should_receive(:connect).and_raise("An error")
      options.new_workers.should be_instance_of(LocalWorkers) 
    end

    it "should return localhost as origin_hostname current hostname is same as when created" do
      options = Options.new({})
      options.origin_hostname.should == 'localhost'
    end

    it "should hostname at instantiation when current hostname is different" do
      local_hostname = Socket.gethostname
      options = Options.new({})
      Socket.should_receive(:gethostname).and_return("host_of_query")
      options.origin_hostname.should == local_hostname
    end

    it "should be able to calculate mirror_path based on base an sync_options" do
      Socket.should_receive(:gethostname).and_return("hostname", "server_hostname")
      options = Options.new(:sync_options => {:source => "/my/source/path"})
      options.mirror_path("/mirror/base/path").should == 
        "/mirror/base/path/hostname_my_source_path"
    end

    it "should raise a useful error if no source is specified" do
      options = DeepTest::Options.new(:sync_options => {})
      lambda {
        options.mirror_path("base")
      }.should raise_error("No source directory specified in sync_options")
    end

    it "should create drb object to connect to server" do
      options = DeepTest::Options.new({})
      server = options.server
      server.__drburi.should == "druby://#{options.origin_hostname}:#{options.server_port}"
    end

    it "should be gathering metrics if metrics file is set" do
      options = DeepTest::Options.new(:metrics_file => "filename")
      options.should be_gathering_metrics
    end

    it "should not be gathering metrics if metrics file is not set" do
      options = DeepTest::Options.new({})
      options.should_not be_gathering_metrics
    end
  end
end
