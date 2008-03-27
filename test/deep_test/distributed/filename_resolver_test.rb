require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "should strip off directories until file exists in base path" do
    resolver = DeepTest::Distributed::FilenameResolver.new("base_path")

    File.expects(:exist?).with("base_path/a/b/c/d.rb").returns(false)
    File.expects(:exist?).with("base_path/b/c/d.rb").returns(false)
    File.expects(:exist?).with("base_path/c/d.rb").returns(true)

    assert_equal "base_path/c/d.rb", resolver.resolve("/a/b/c/d.rb")
  end

  test "should resolve relative names starting at first element" do
    resolver = DeepTest::Distributed::FilenameResolver.new("base_path")

    File.expects(:exist?).with("base_path/a/b/c/d.rb").returns(true)

    assert_equal "base_path/a/b/c/d.rb", resolver.resolve("a/b/c/d.rb")
  end

  test "should resolve relative names the same each time" do
    resolver = DeepTest::Distributed::FilenameResolver.new("base_path")

    File.expects(:exist?).with("base_path/a/b/c/d.rb").returns(true)

    assert_equal "base_path/a/b/c/d.rb", resolver.resolve("a/b/c/d.rb")
    assert_equal "base_path/a/b/c/d.rb", resolver.resolve("a/b/c/d.rb")
  end

  test "should raise exception if filename can't be resolved" do
    resolver = DeepTest::Distributed::FilenameResolver.new("base_path")

    File.expects(:exist?).with("base_path/a/b/c/d.rb").returns(false)
    File.expects(:exist?).with("base_path/b/c/d.rb").returns(false)
    File.expects(:exist?).with("base_path/c/d.rb").returns(false)
    File.expects(:exist?).with("base_path/d.rb").returns(false)

    assert_raises(RuntimeError) { resolver.resolve("/a/b/c/d.rb") }
  end

  test "should remember how many directories to strip off after first resolution" do
    resolver = DeepTest::Distributed::FilenameResolver.new("base_path")

    File.expects(:exist?).with("base_path/a/b/c/d.rb").returns(false)
    File.expects(:exist?).with("base_path/b/c/d.rb").returns(true)
    
    resolver.resolve("/a/b/c/d.rb")

    assert_equal "base_path/x/y/z.rb", resolver.resolve("/a/x/y/z.rb")
  end
end
