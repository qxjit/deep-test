=begin rdoc
Module, like open3.rb, except that instead of exec'ing some other command,
call's a ruby Proc object instead.

Forks a process, which is an exact byte for byte copy of this one,
but with no way of communicating with the parent.

Thus it also creates a set of three pipes, and ties them to
the stdin, stdout and stderr of the child process and
returns the three pipes to the parent.

The child process then calls the proc_obj with the args.

stdin,stdout,stderr = ropen3( proc_obj, arg1, arg2, ...)
=end

def ropen3(proc_obj,*arg)
  pw = IO::pipe   # pipe[0] for read, pipe[1] for write
  pr = IO::pipe
  pe = IO::pipe

  pid = Process.fork {
    # child
    Process.fork {
      # grandchild
      pw[1].close
      STDIN.reopen(pw[0])
      pw[0].close

      pr[0].close
      STDOUT.reopen(pr[1])
      pr[1].close

      pe[0].close
      STDERR.reopen(pe[1])
      pe[1].close

      proc_obj.call(*arg)
    }
    exit!
  }

  pw[0].close
  pr[1].close
  pe[1].close
  begin
    Process.waitpid(pid)
  rescue Errno::ECHILD => details
    # It's OK if child goes away before we collect it!
  end

  pi = [pw[1], pr[0], pe[0], pid]
  pw[1].sync = true
  if defined? yield
    begin
      return yield(*pi)
    ensure
      pi.each{|p| p.close unless p.closed?}
    end
  end
  pi
end

if $0 == __FILE__ then
  require 'test/unit'

  
  class TC_TestROpen3 < Test::Unit::TestCase
    
    def test_ropen3
      puts "In test_reopen3"
      proc_obj = Proc.new  do |n|
        (1..n).each do |i|
          puts i
        end
      end

      stdin, stdout, stderr, pid = ropen3( proc_obj, 3)
      assert( pid > 1)
      assert_equal( "1\n", stdout.gets)
      assert_equal( "2\n", stdout.gets)
      assert_equal( "3\n", stdout.gets)
      assert( stdout.gets.nil?)
    end

    def test_echo
      puts "In test_echo"
      proc_obj = Proc.new do 
        STDIN.each do |line|
          print line
        end
      end

      stdin, stdout, stderr, pid = ropen3( proc_obj, 3)
      assert( pid > 1)

      puts "Done ropen3"
      stdin.puts "Foo!"
      assert_equal( "Foo!\n", stdout.gets)
      stdin.puts "Goo!"
      assert_equal( "Goo!\n", stdout.gets)
      stdin.puts "Foo! Bah!"
      assert_equal( "Foo! Bah!\n", stdout.gets)
    end
  end
end




