require 'dyad'

on_error = lambda { |event| puts event.msg }
on_data = lambda do |event|
  event.stream.write(event.data, event.length)
  puts event.stream.get_bytes_sent
end
on_accept = lambda do |event|
  event.remote.add_listener(:EVENT_DATA, on_data, nil)
  event.remote.write("echo server\r\n")
end

Dyad.init
stream = Dyad::Stream.new
stream.add_listener(:EVENT_ERROR, on_error, nil)
stream.add_listener(:EVENT_ACCEPT, on_accept, nil)

stream.listen(8000)

while Dyad.get_stream_count
  Dyad.update
end
