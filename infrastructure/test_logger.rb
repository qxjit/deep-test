class TestLogger < DeepTest::Logger
  def initialize(device = nil)
    super(StringIO.new)
  end

  def logged_output
    io_stream.string
  end
end


