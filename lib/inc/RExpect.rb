=begin rdoc
RExpect.rb - A better expect


== Overview

A class to drive/interact/control other programs / devices / objects
in a manner similar to (or preferably better than) 'expect'.

=== Why use RExpect instead of expect.rb?

Performance. I wanted to be able to run hundreds of virtual tasks at
once and expect.rb's algorithm of eating the input character by
character was just plain _way_ too slow.

== Todo

Probably should seperate this into two classes. RExpect should know
only about events on input streams. The other class should know about
creating and babysitting subprocesses.

=end

require 'pty'
require 'thread'
require 'timeout'
require 'ropen3'
require 'stringio'


# David Vollbracht: only set verbose if it hasn't been set
#  (for instance, DeepTest doesn't want verbose)
$expect_verbose = true if $expect_verbose.nil?

=begin rdoc

PTY.spawn is a Bad Thing. Not the ruby implementation, but
the very POSIXy definition itself!

Suppose you tell it to spawn off a command that doesn't exist....
What do you think will happen?
1) You get a sane error code?
2) It raises an appropriate Exception?
3) Returns quite happily and at some random time later, throws a
PTY::ChildExited exception?

Yup. Option 3) is what happens.
Evil isn't it?!

So suppose we firing of hundreds of these spawns, the
system grows slower and slower, the random interval
between returning from spawn and the PTY::ChildExited
becomes larger and the whole thing gets more and more mysterious.

Clearly we need to cope with this somehow.

Solution: Evil, Dramatic, Simple, It Works...
Ignore SIGCHLD!
SIGCHLD just plain cause trouble with Spawn. Better just to ignore
them!

If anyone works out a better solution that will pass all the Unit
tests, I will be very happy!

=end

# David Vollbracht: commented out to get rid of 'No child processes' messages
# being printed from deep_test.
# 
# The comment above would seem not to apply to us.  We only ever execute rsync,
# and if that doesn't exist, distributed DeepTest won't work at all!
#
#Signal.trap( 'CHLD', 'IGNORE')

# Raised if command fails to product a prompt in reply.
class NoPromptException < Exception
end

# Same API as the standard library 'logger' ie. RExpect can use the
# standard 'logger', or the NiftyLogger provided here.
# If logs like a duck, it's a duck logger.
class AbstractLogger
  private
  def default_output(msg)
  end

  public

  def initialize(*rest)
  end
  
  def debug(msg)
    default_output(msg)
  end

  def info(msg)
    default_output(msg)
  end

  def warn(msg)
    default_output(msg)
  end

  def error(msg)
    default_output(msg)
  end

  def fatal(msg)
    default_output(msg)
  end
end

# A trivial implementation of a logger.
class NiftyLogger < AbstractLogger
  def initialize( *rest)
    @log = File.open(rest[0], 'w')
    @log.sync = true
    @mutex = Mutex.new
  end

  private
  def default_output(msg)
    t = Time.new
    hms = t.strftime('%H:%M:%S.')
    hh = sprintf('%02d',(t.usec/1e4).to_i)
    string = "#{caller(2)[0]}:#{hms}#{hh}:#{msg}"
    @mutex.synchronize do
      @log.puts string
      puts string
    end
  end
end

# Ignore all output...
class DevNull
  def sync=(bool)
  end

  def puts( msg)
  end
end

=begin rdoc

== Responsibility

A RExpect object watches, in real time, an input stream for
occurrences of a string of characters matching a specified Regexp.

The RExpect class also provides services for creating & watching such
streams via either...
* RExpect.spawn(cmd,...) which spawn's a new process attached to a pseudo terminal.
* RExpect.fork(proc_obj,...) which fork's a new Ruby process, and call
  the Proc object in the new process interacts with it's STDIN / STDOUT via pipes.
* RExpect.new(inf,outf,...) creates a new RExpect watcher on preexisting IO objects.

== Collaborators 

[Pty] for creating pseudo terminals. Allows you to control programs
      that have an implicit expectation of being run interactively from a terminal.

[Thread] For creating a separate Thread of control to suck on the inputs.
[Mutex] For Thread synchronization.
[ConditionVariable] For synchronizing access to the shared buffer resource.
[Regexp] We look for incoming strings that match a Regexp.
[String] Holds the buffer of data seen and unmatched so far.

== State held

* @inf, @outf - Holds input and output IO's
* @e_pat - a Regexp pattern to match, 
* @buffer - and a databuffer of characters seen and unmatched so far..
* @mutex, @bufferResource - A Mutex and ConditionVariable to synchronize access to @buffer and @e_pat
* @pid - To enable you to kill and wait on the subprocess.

* @@logger - One logger for the class.
* @time_out - Default time_out for instance
* @prompt - Default command prompt pattern for instance.

== Invariant

@e_pat should never match @buffer on exit of a public method.

== Concurrency

Each instance should only be accessed by a single Thread. However, you
may have as many instances as you like in as many Threads as you like.

=end

class RExpect
  # The pid of supprocess.
  attr_reader :pid

  # For use by 'cmd'. Will puts cmd to outf, then expect( @prompt)
  attr_accessor :prompt
  

  # The default time out in seconds.
  attr_accessor :time_out

  @@log = AbstractLogger.new

  # Spawn's command 'cmd' as a new subprocess in a
  # pseudo terminal and returns an RExpect instance.
  #
  # [+cmd+] - String - The command line command that will be executeed.
  # [+max_buffer_size+] - Integer - Maximum buffer to hold.
  # [+time_out+] - The default time out value in seconds for calls to expect. If nil (the default) wait forever.
  #
  # === Returns
  # A RExpect instance tied to the pseudo terminal unless a block is
  # given, in which case it returns the value returned by the block.
  #
  # === Effects
  # The command 'cmd' is executed and the stdout of that command is tied to the RExpect
  # instances input and the stdin of that command is tied to output of the RExpect object.
  #
  # If a block is given, the block is passed the RExpect instance
  # which is +kill+ed on exit from the block.
  #
  # === Algorithm
  # Use Pty.spawn which creates a pseudo term to fool commands that expect to live in an
  # interactive terminal / command line environment that all is well.
  #
  # === Operational Constraints
  # The SIGCHLD signal comes at random times depending on load making
  # it impossible to live reliably with it.  So I have switched it
  # off. You don't really need it since you get an EOFError at the
  # appropriate time anyway.
  #
  # === Example
  # See TC_TestRExpect.test_cmd
  #
  # === Todo
  # Find a way to live with SIGCHLD.
  #
  # === Bugs
  # None known
  def RExpect.spawn(cmd, max_buffer_size=1024, time_out=nil)
    @@log.info "Spawn #{cmd}"
    inf, outf, pid = PTY.spawn(cmd)
    @@log.info "Spawned cmd"
    @@log.info "creating RExpect instance"
    result = RExpect.new(inf, outf, pid, max_buffer_size, time_out)

    if block_given?
      retval = yield result
      result.kill
      return retval
    else
      return result
    end
  end

  def close
    @open = false
  end

  # Getter for the class logger.
  #
  # === Returns
  # Logger that conforms to AbstractLogger interface
  def RExpect.logger
    @@log
  end

  # Setter for the class logger.
  #
  # [+a_logger+] A logger that conforms duck-wise to the AbstractLogger interface
  #
  # === Returns
  # Previous value of @@logger.
  #
  # === Effects
  # RExpect class logger set to a_logger
  def RExpect.logger=(a_logger)
    old_logger = @@log
    @@log = a_logger
    old_logger
  end

  # class Factory method for creating a ruby subprocess running a proc object.
  #
  # [+proc_obj+] The proc_object to +call+ in the child process.
  # [+*arg+] arguments to pass to the proc object.
  #
  # === Returns
  # Returns a RExpect instance tied to the STDOUT and STDIN of the
  # subprocess, unless a block is given, in which case it returns the
  # value returned by the block.
  #
  # === Effects
  # A ruby subprocess is fork'd and the STDIN and STDOUT is pipe'd to the output
  # and inputs of a RExpect instance
  #
  #
  # If a block is given, the block is passed the RExpect instance
  # which is +kill+ed on exit from the block.
  #
  # === Algorithm
  # See ropen3
  #
  # === Bugs.
  # The STDERR of the subprocess is ignored.
  def RExpect.fork(proc_obj, *arg)
    inf, outf, err, pid = ropen3(proc_obj, *arg)
    result = RExpect.new( outf, inf, pid)
    
    if block_given?
      retval = yield result
      result.kill
      return retval
    else
      return result
    end

    result
  end
  
  # Construct a new instance of RExpect.
  #
  # [+inf+] Input IO to be watched for incoming matching Regexp
  # [+outf+] Output IO to send commands to.
  # [+pid+] Process id of process being watched.
  # [+max_size+] Maximum size of buffer to maintain.
  # [+time_out+] Default time out in seconds. ie. How long to wait for Regexp to appear.
  #
  # === Returns
  # New RExpect instance tied to inf, outf.
  #
  # === Effects
  # A new Thread is created which immediately starts to suck on @inf.
  #
  # === Operational Constraints
  # Unless you invoke the expect method, the buffer may grow without limit.
  #
  def initialize(inf,outf=DevNull.new,pid=nil,max_size=1024,time_out=nil)
    @inf,@outf,@pid,@max_size = inf,outf,pid,max_size
    @outf.sync=true

    # The input thread packs the data into the buffer
    @buffer = ''

    # Synchronise with input thread via this mutex.
    @mutex = Mutex.new
    @bufferResource = ConditionVariable.new

    # Regexp to match on.
    # All future accesses to this variable must be synchronized!
    @e_pat = nil

    @time_out = time_out
    @time_out = 5 unless @time_out

    @input_thread = Thread.new do
      # David Vollbracht: Set abort_on_exception locally instead
      #
      Thread.current.abort_on_exception = true
      input_data
    end
  end

  # Hmm. I'm not sure this is the right API for interact
  def interact(str)
    @outf.print str
  end

  # If have @pid, wait for subprocess to die else return nil
  #
  # === Returns
  # child exit status or nil
  #
  # === Effects
  # Wait's until child process specified by @pid exits.
  # If @pid is nil, returns nil immediately
  def wait
    if @pid
      Process.waitpid(@pid,0) 
    else
      nil
    end
  end

  # Kill subprocess with signal
  # [+signal+] See Process.kill
  #
  # === Returns
  # Child's exit status. See wait
  #
  # === Effects
  # The signal is sent to child via Process.kill
  # The we wait for child to exit and return it's exit status.
  def kill( signal = "SIGTERM")
    begin
      Process.kill( signal, @pid)
    rescue SystemCallError => e
      # Nothing to kill
    end
    wait
  end

  # Tell's the RExpect instance to watch for the appearance of a
  # string matching a Regexp on the input stream. Blocks until either
  # a string matches or we timeout.
  #
  # [+pat+] 
  #  If pat responds_to? :match, watches input stream until pat.match(@buffer)
  #  If pat is a kind_of? String, converts it to a Regexp via Regex.new(Regexp.quote(pat))
  # [+time_out+] Time to wait for appearance of pattern. If time_out is nil, use the 
  # default value given at the time of the creation of the RExpect instance.
  #
  # === Returns
  # Returns the result of converting the MatchData object to an Array
  # (to conform to expect API)
  #
  # === Effects
  # If no match is found before time out, a Timeout::Error is raised.
  # If EOF is reached an EOFError is raised.
  # If a match is found, everything up to and including the match is deleted
  # from the buffer.
  #
  # === Operation Constraints
  # While we are trying to match a pattern, characters are dropped from the buffer in a
  # fifo manner as the buffer grows beyond @max_size.
  def expect(pat,time_out=nil)
    unless time_out
      time_out = @time_out
    end

    @result = nil

    @mutex.synchronize do
      if pat.respond_to? :match
        @e_pat = pat
      elsif pat.kind_of? String
        @e_pat = Regexp.new(Regexp.quote(pat))
      else
        p pat
        raise "Expected pat to to respond_to? :match. pat is a #{pat.class}"
      end

      @@log.info( "Expecting /#{@e_pat.source}/")

      match_data = @e_pat.match(@buffer)
      if match_data
        @result = match_data.to_a
        @buffer = match_data.post_match
        @@log.info( "Existing buffer matched /#{@e_pat.source}/")
        @e_pat = nil
        return @result
      end

      raise EOFError unless @open

      begin
        timeout( time_out) do
          @bufferResource.wait( @mutex)
          raise EOFError if @result.nil?
        end
      rescue Timeout::Error => details
        @@log.info( "Timed out after #{time_out} seconds")
        @@log.info( "Timeout error details '#{details}'")
        @@log.info( "Current buffer is ...\nBUFFER:#{@buffer}")
        @@log.info( "Currently trying to match...\n/#{@e_pat.source}/")
        raise details
      end
    end
    return @result
  end

  # Arguments are an array of pairs, it returns the first element of
  # the pair if the second element matches.
  # The second element must be a string not a regex.
  # Returns token corresponding to the first matching string.
  #
  # [+pair1, pair2, pair3, ...+] Pairs to find.
  #
  # === Returns
  # Returns second element of pair if first element matches,
  #
  # === Example
  # rex.expect_one_of( [/user(name)?.*\n/, 'name'], [/password|passwd/, 'password'])
  # Will match input...
  #  Enter your username :-
  # and return the String "name"
  #
  # === Algorithm
  # Or's "|" all the patterns together then scans the list of pairs
  # to see which pair matched, and returns the corresponding second element.
  def expect_one_of( *array_of_pairs)
    raise "Expect one of called without any pairs!" if array_of_pairs.length < 1
    token, pattern = array_of_pairs.shift
    pattern = duck_type_string_pattern(pattern)
    regex = pattern.source
    all = [[pattern, token]]
    array_of_pairs.each do |token,pattern|
      pattern = duck_type_string_pattern( pattern)
      regex += "|"+pattern.source
      
      all << [pattern,token]
    end
    match = expect(Regexp.new( regex, Regexp::MULTILINE))
    unless match
      @@log.info "Expect_one_of didn't match anything"
      return nil
    end

    matching_string = match[0]
    all.each do |regex, token|
      if regex.match( matching_string)
        @@log.info "Matching string '#{matching_string}' corresponded to '#{token}'"
        return token 
      end
    end
    pp all
    raise "Matched '#{matching_string}', didn't find match infernal error!"
  end

  # Expect pattern, ignore time out.
  def hopefor(pattern, time_out=nil)
    @@log.info("Hope for #{pattern}")
    begin
      expect(pattern, time_out)
    rescue TimeoutError
      nil
    end
  end

  # Empty the buffer.
  def clearBuff
    @@log.info("Clearing buffer")
    @mutex.synchronize {
      @buffer = ''
    }
    @@log.info("Buffer is now #{@buffer}")
  end

  # Sends str to outf (the prawned process.)
  def puts(str)
    @@log.info( str)
    @outf.puts str
  end 

  # Send command str to prawned process, wait from prompt,
  # raise NoPromptException if  if you don't get it.
  def cmd(str, time_out=nil)
    puts str
    expect( @prompt, time_out)
  rescue Timeout::Error, EOFError => details
    raise NoPromptException, "No prompt found after issuing '#{str}' - #{details}"
  end


  private

  def match_input( data)
    @@log.info( "\nBUFFER:#{@buffer}\nNEWDATA:#{data}" )
    # Stuff it in buffer.
    
    @buffer << data
    
    if @e_pat # Has anyone invoked the :expect method yet?
      match_data = @e_pat.match(@buffer)
      if match_data # Yip, we match
        # The result is the buffer and the matched ()'d fields
        @result = match_data.to_a
        # Chomped off the stuff matched so far...
        @buffer = match_data.post_match
        @@log.info( "Buffer matched /#{@e_pat.source}/")
        @@log.info( "Match is \"#{@result[1]}\"") if !@result[1].nil?
        
        # Drop this pattern, we'll have to invoke :expect again before
        # we match again.
        @e_pat = nil
        
        # Signal the main thread to wake up.
        @bufferResource.signal
      end

      # Trim the buffer
      if @buffer.length > @max_size
        @buffer = @buffer[-@max_size .. -1]
      end
    end
  end


  # This should be only invoked from a seperate thread to the one
  # that invokes the :expect method.
  #
  # Typically you would use RExpect.spawn or RExpect.fork rather
  # than invoke this directly.
  def input_data
    @open = true

    # Keep sucking while there is data
    while @open
      # Read in large chunks.
      data = @inf.sysread( 65536)
      
      # We have good data, so we need to stuff it in the buffer.
      # Grab mutex.
      @mutex.synchronize do
        match_input( data)
      end
    end
  rescue EOFError, Errno::EIO
    # What happens if if we have reached end of
    # file? Well, if we haven't matched yet we never will.
    @open = false

    @mutex.synchronize do
      if @e_pat
        @@log.info "EOF, match not found!" 
        @result = nil
        # Tell main thread to wake.
        @bufferResource.signal
      else
        @@log.info "End of file reached on input sucking thread, exiting quietly"
      end
    end
  end

  def duck_type_string_pattern( pattern)
    return pattern if pattern.respond_to? :source
    Regexp.new(string, Regexp::MULTILINE)
  end
end

# If the global variable has been set before the "require 'RExpect',
# open log file.
if $expect_verbose then
  RExpect.logger = NiftyLogger.new( "rexpect.log.#{Process.pid}")
end

if $0 == __FILE__ then
  require 'test/unit'
  require 'pp'
  require 'rbconfig'

  STDOUT.sync = true
  STDERR.sync=true


  class TC_TestRExpect < Test::Unit::TestCase

    def who_am_i
      msg = sprintf( "\n%-40s   <================\n\n", caller()[0])
      print msg
      RExpect.logger.info msg
    end
    
    def test_RExpect
      who_am_i
      proc_obj = Proc.new do |state|
        case state
        when :test1
          puts "
T'was brillig and the slithy toves
did gyre and gimble
in the wabe..."
        else
        end
      end

#      stdin,stdout,stderr = ropen3( proc_obj, :test1)

 #     rex = RExpect.new()
    end

    def test_pty_spawn_bad_command
      who_am_i
      inf, outf, pid = PTY.spawn( "UnknownCommand")
      # The above, strangely enough passes OK.
      p inf.gets # First suck gets and error message!
      p inf.gets # Second suck bombs
      assert( false)
    rescue Errno::EIO => details
      assert(true)
      puts details
    end

    def test_pty_spawn_good_command_that_exist
      who_am_i
      inf, outf, pid = PTY.spawn( "/bin/echo boo")
      assert_equal( "boo\r\n", inf.gets) # Cute, note \r
      sleep 2
      assert(true)
    end

    def test_pty_spawn_can_suck_even_if_late
      who_am_i
      inf, outf, pid = PTY.spawn( "yes yes | head -3")
      sleep 2
      assert_equal( "yes\r\n", inf.gets) # Cute, note \r
      sleep 1
      assert_equal( "yes\r\n", inf.gets) # Cute, note \r
      sleep 1
      assert_equal( "yes\r\n", inf.gets) # Cute, note \r
      sleep 1
      assert_equal( "yes\r\n", inf.gets) # Cute, note \r
      assert( false)
    rescue Errno::EIO => details
      assert(true)
      puts details
    end

    def test_pty_spawn_expect
      who_am_i
      rex = RExpect.spawn( "/bin/echo boo")

      puts "Prawned echo boo"

      assert(rex.expect( /boo/))

      puts "Found boo"

      puts "Sleep to see if we're hit by any ChildExited errors..."
      sleep 2
      puts "End"
    end

    def test_large_buffer
      who_am_i
      old_logger = RExpect.logger = AbstractLogger.new
      rex = RExpect.spawn("cat /dev/urandom")

      assert_raise(Timeout::Error) {||rex.expect(/Very Totally Unlikely/, 5)}
    ensure
      RExpect.logger=old_logger
    end

    def test_small_buffer
      who_am_i
      StringIO.open("tiny") do |inf|
        p inf.sysread
        assert_raises( EOFError) {inf.sysread}
      end

      StringIO.open("tiny") do |inf|
        rex = RExpect.new( inf)
        rex.expect( /ti/)
        rex.expect( /ny/)
        assert_raises( EOFError){rex.expect( /WILL NOT FIND THIS!/)}
      end
    end

    def test_expect_one_of
      who_am_i
      rex = RExpect.spawn( "ruby -e 'puts \"tom\ndick\nharry\n\";sleep 2'")
      assert_equal( :dick, rex.expect_one_of( [:terry, /dactyl/], [:dick, /dick/], [:hairy, /beard/]))
    end

    def test_cmd
      who_am_i
      rex = RExpect.spawn( "bash")
      rex.prompt = /[\r\n][^\r\n]+[\$#] /
      rex.cmd( 'ls')
      rex.cmd( 'pwd')
      rex.puts('exit')
      sleep 1
    end

    if RbConfig::CONFIG['target_os'] == 'linux'
      def test_ls
        who_am_i
        rex = RExpect.spawn( "/bin/ls #{__FILE__}") # Platform dependency BAD! Should if around this!
        rex.expect( /#{__FILE__}/)
      end
    end

    def test_ropen3
      who_am_i
      yesyes = Proc.new do |n|
        (0..n).each do |i|
          puts "Yes"
        end
      end
      
      rex = RExpect.fork( yesyes, 100)
      rex.expect( /Yes/)
    end
  end
end
