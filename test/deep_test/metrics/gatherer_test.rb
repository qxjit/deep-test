require File.dirname(__FILE__) + "/../../test_helper"

unit_tests do
  test "section uses block to add measurements when render is called" do
    i = j = 0
    section = DeepTest::Metrics::Gatherer::Section.new("my section") do |s|
      s.measurement("i", i)
      s.measurement("j", j)
    end

    i = 1
    j = 2

    rendered_string = section.render

    assert_match /^i: 1$/, rendered_string
    assert_match /^j: 2$/, rendered_string
  end

  test "section starts with title" do
    section = DeepTest::Metrics::Gatherer::Section.new("my section") {|s|}
    assert_equal "[my section]\n", section.render
  end

  test "gatherer renders all sections defined" do
    gatherer = DeepTest::Metrics::Gatherer.new(DeepTest::Options.new(:metrics_file => "something"))
    gatherer.section("section 1") {|s|}
    gatherer.section("section 2") {|s|}

    assert_equal "[section 1]\n\n[section 2]\n", gatherer.render
  end

  test "no sections are added if not gathering metrics" do
    gatherer = DeepTest::Metrics::Gatherer.new(DeepTest::Options.new({}))
    gatherer.section("section 1") {|s|}
    gatherer.section("section 2") {|s|}

    assert_equal "", gatherer.render
  end

  test "enabled? is true if metrics_file is specified" do
    gatherer = DeepTest::Metrics::Gatherer.new(DeepTest::Options.new(:metrics_file => "something"))
    assert_equal true, gatherer.enabled?
  end

  test "enabled? is false if metrics_file is not specified" do
    gatherer = DeepTest::Metrics::Gatherer.new(DeepTest::Options.new({}))
    assert_equal false, gatherer.enabled?
  end

  test "write_file writes rendered contents to metrics file" do
    gatherer = DeepTest::Metrics::Gatherer.new(
      DeepTest::Options.new(:metrics_file => "a_file")
    )
    gatherer.section("section 1") {|s|}
    File.expects(:open).with("a_file", "w").yields(io = StringIO.new)
    gatherer.write_file
    assert_equal gatherer.render, io.string
  end

  test "write_file does nothing if not enabled" do
    gatherer = DeepTest::Metrics::Gatherer.new(DeepTest::Options.new({}))
    File.expects(:open).never
    gatherer.write_file
  end
end
