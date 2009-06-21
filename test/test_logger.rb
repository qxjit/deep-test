class TestLogger < DeepTest::Logger
  def initialize
    super(StringIO.new)
  end

  def logged_output
    @logdev.dev.string
  end
end


