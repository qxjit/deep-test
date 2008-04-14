module DeepTest
  module Metrics
    module QueueLockWaitTimeMeasurement
      attr_reader :total_pop_time, :total_push_time

      def self.extended(o)
        o.instance_eval do
          alias pop_without_lock_wait_measurement pop
          alias pop pop_with_lock_wait_measurement

          alias push_without_lock_wait_measurement push
          alias push push_with_lock_wait_measurement
        end
      end

      def pop_with_lock_wait_measurement(no_wait = false)
        if no_wait
          return measure(:add_pop_time) do
            pop_without_lock_wait_measurement(no_wait)
          end
        else
          begin
            # Measure without waiting to minimize extra time added
            # above locking time
            #
            return measure(:add_pop_time) do
              pop_without_lock_wait_measurement(true)
            end
          rescue ThreadError => e
            if e.message == "queue empty"
              # Normally we would have waiting for a condvar signal,
              # so don't penalize time for locking here again - hence
              # no measure
              return pop_without_lock_wait_measurement(false)
            else
              raise
            end
          end
        end
      end

      def push_with_lock_wait_measurement(value)
        measure(:add_push_time) do
          push_without_lock_wait_measurement(value)
        end
      end

      def measure(accumulator)
        start_time = Time.now
        result = yield
        send(accumulator, Time.now - start_time)
        result
      end

      def add_push_time(time)
        Thread.exclusive do
          @total_push_time ||= 0
          @total_push_time += time
        end
      end

      def add_pop_time(time)
        Thread.exclusive do
          @total_pop_time ||= 0
          @total_pop_time += time
        end
      end
    end
  end
end


if $0 == __FILE__
  require 'thread'
  require 'timeout'

  thread_count = (ARGV[0] || 10).to_i
  action_count = (ARGV[1] || 100).to_i

  def test_measurement(thread_count, action_count)
    q = Queue.new
    q.extend DeepTest::Metrics::QueueLockWaitTimeMeasurement

    threads = []
    thread_count.times do
      threads << Thread.new do
        action_count.times do |i|
          show_progress ".", action_count, i
          q.push 1
        end
      end
    end

    thread_count.times do
      threads << Thread.new do
        action_count.times do |i|
          show_progress "-", action_count, i
          if rand(2) == 0
            begin
              q.pop(true)
            rescue ThreadError
            end
          else
            begin
              Timeout.timeout(0.01) do
                q.pop
              end
            rescue Timeout::Error
              break
            end
          end
        end
      end
    end

    threads.each {|t| t.join}

    puts
    puts "Push Time: #{q.total_push_time}"
    puts "Pop Time:  #{q.total_pop_time}"
  end

  def show_progress(s, total, current)
    if (current % (total / 5)) == 0
      $stdout.print s
      $stdout.flush
    end
  end

  start_time = Time.now
  test_measurement(thread_count, action_count)
  puts "Total Run Time:  #{Time.now - start_time}"
end
