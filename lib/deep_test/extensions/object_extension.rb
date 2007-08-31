module DeepTest
  module ObjectExtension
    def capture_stdout
      old_stdout, $stdout = $stdout, StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end
end
Object.send :include, DeepTest::ObjectExtension
