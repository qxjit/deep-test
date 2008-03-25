require 'socket'

name = Socket.gethostname
puts "Host: #{name}"
puts "Host: #{Socket.gethostbyname(name).inspect}"

def time(task)
  start = Time.now
  yield
  finish = Time.now
  puts "#{task}: #{finish.to_f - start.to_f}s"
end

def time_socket(host)
  time(host) do
    begin
      soc = TCPSocket.open(host, 22)
    ensure
      soc.close if soc
    end
  end
end

time_socket('localhost')
time_socket(name)
