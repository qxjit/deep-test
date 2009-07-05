require File.dirname(__FILE__) + "/../test_helper"

module DeepTest
  unit_tests do
    class FooDemon; include Demon; end
    class BarDemon; include Demon; end

    test "triage is not fatal if a heart monitor of the specified type has beeped in the last 5 seconds" do
      medic = Medic.new
      monitor = at("12:00:00") { medic.assign_monitor FooDemon }
      at("12:01:01") { monitor.beep }
      at("12:01:06") { assert_equal false, medic.triage(FooDemon).fatal? }
    end

    test "triage is not fatal if any of multiple heart monitors has beeped" do
      medic = Medic.new
      monitor_1 = at("12:00:00") { medic.assign_monitor FooDemon }
      monitor_2 = at("12:00:00") { medic.assign_monitor FooDemon }
      at("12:01:01") { monitor_1.beep }
      at("12:01:06") { assert_equal false, medic.triage(FooDemon).fatal? }
      at("12:01:07") { monitor_2.beep }
      at("12:01:12") { assert_equal false, medic.triage(FooDemon).fatal? }
    end

    test "triage is fatal if no heart monitor has beeped for 5 seconds" do
      medic = Medic.new
      at("12:01:00") { medic.assign_monitor FooDemon }
      at("12:01:06") { assert_equal true, medic.triage(FooDemon).fatal? }
    end

    test "triage is fatal if monitor beeped more than 5 seconds ago" do
      medic = Medic.new
      monitor = at("12:01:00") { medic.assign_monitor FooDemon }
      at("12:01:01") { monitor.beep } 
      at("12:01:07") { assert_equal true, medic.triage(FooDemon).fatal? }
    end

    test "triage is fatal if monitor of another type has beeped" do
      medic = Medic.new
      foo_monitor = at("12:00:00") { medic.assign_monitor FooDemon }
      at("12:01:00") { medic.assign_monitor FooDemon }
      at("12:01:00") { medic.assign_monitor BarDemon }
      at("12:01:01") { foo_monitor.beep }
      at("12:01:06") { assert_equal true, medic.triage(BarDemon).fatal? }
    end

    test "triage is not fatal if no monitors have been assigned but none have been expected" do
      medic = at("12:00:00") { Medic.new }
      at("12:00:06") { assert_equal false, medic.triage(FooDemon).fatal? }
    end

    test "triage is fatal no monitors have been assigned but some where expected" do
      medic = Medic.new
      at("12:00:00") { medic.expect_live_monitors FooDemon } 
      at("12:00:06") { assert_equal true, medic.triage(FooDemon).fatal? }
    end

    test "triage is not fatal if no monitors have been assigned but none have been expected for the given type" do
      medic = at("12:00:00") { Medic.new }
      at("12:00:00") { medic.expect_live_monitors BarDemon } 
      at("12:00:06") { assert_equal false, medic.triage(FooDemon).fatal? }
    end

    test "triage is not fatal if no monitors have been assigned but less than 5 seconds has passed since they were expected" do
      medic = Medic.new
      at("12:00:00") { medic.expect_live_monitors FooDemon } 
      at("12:00:05") { assert_equal false, medic.triage(FooDemon).fatal? }
    end

    test "beep returns nil so nothing is serialized over the wire" do
      assert_equal nil, Medic.new.assign_monitor(FooDemon).beep
    end

    test "monitor will not be dumped over the wire after assignment" do
      assert_kind_of DRb::DRbUndumped, Medic.new.assign_monitor(FooDemon)
    end

    test "medic will not be dumped over the wire after assignment" do
      assert_kind_of DRb::DRbUndumped, Medic.new
    end

    def at(time, &block)
      Timewarp.freeze(time, &block)
    end
  end
end
