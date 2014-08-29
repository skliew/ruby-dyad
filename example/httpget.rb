require 'dyad'

Dyad.init

stream = Dyad::Stream.new

stream.add_listener(:EVENT_CLOSE) do |event|
  puts "Closed"
end
stream.add_listener(:EVENT_CONNECT) do |event|
  event.stream.write("GET / HTTP/1.0\r\n\r\n")
end
stream.add_listener(:EVENT_ERROR) do |event|
  puts event.msg
end
stream.add_listener(:EVENT_DATA) do |event|
  puts event.data
end
stream.connect("xkcd.com", 80)

while Dyad.get_stream_count > 0
  Dyad.update
end

Dyad.shutdown
