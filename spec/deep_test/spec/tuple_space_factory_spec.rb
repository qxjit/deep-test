require File.dirname(__FILE__) + "/../../spec_helper"

module DeepTest
  describe TupleSpaceFactory do
    describe "tuple_space" do
      before :each do
        DRb.stub!(:start_service)
        @ring_finger = mock("Rinda::RingFinger")
        Rinda::RingFinger.stub!(:new).and_return @ring_finger
        
        @tuple_space = mock("TupleSpace", :__drburi => nil)
        @ring_finger.stub!(:lookup_ring_any).and_return @tuple_space
        
        @hostnames = ["escher"]
        TupleSpaceFactory.stub!(:hostnames).and_return @hostnames
        @options = OpenStruct.new({:server_port => "2020"})
        
        @fake_logger = mock("logger", :null_object => true)
        DeepTest.stub!(:logger).and_return @fake_logger
        
        @tuple_space_proxy = mock("TupleSpaceProxy")
        Rinda::TupleSpaceProxy.stub!(:new).and_return @tuple_space_proxy
      end
      
      it "should start the drb service" do
        DRb.should_receive(:start_service).with(no_args)
        TupleSpaceFactory.tuple_space(@options)
      end
      
      it "should create a new RingFinger" do
        Rinda::RingFinger.should_receive(:new).with(@hostnames, "2020").and_return @ring_finger
        TupleSpaceFactory.tuple_space(@options)
      end
      
      it "should create a new RingFinger with the appropriate socket number" do
        @options.server_port = 4062
        
        Rinda::RingFinger.should_receive(:new).with(@hostnames, 4062).and_return @ring_finger
        TupleSpaceFactory.tuple_space(@options)
      end
      
      it "should lookup any ring that the ring finger can find" do
        @ring_finger.should_receive(:lookup_ring_any).and_return @tuple_space
        TupleSpaceFactory.tuple_space(@options)
      end
      
      it "should create a new TupleSpaceProxy with the tuple space previously found" do
        Rinda::TupleSpaceProxy.should_receive(:new).with(@tuple_space)
        TupleSpaceFactory.tuple_space(@options)
      end
    end
    
    describe "hostnames" do
      before :each do
        @hostname = "escher"
        Socket.stub!(:gethostname).and_return @hostname
      end
      
      it "should return an array with the hostname and 'localhost'" do
        TupleSpaceFactory.hostnames.should == ["escher", "localhost"]
      end
    end
  end
end