require 'dyad'

Dyad.init
stream = Dyad::Stream.new
stream.add_listener(:EVENT_ERROR) {|event| puts event.msg }

stream.add_listener(:EVENT_ACCEPT) do |event|
  event.remote.add_listener(:EVENT_DATA) do |data_evt|
    data_evt.stream.write(data_evt.data, data_evt.length)
  end
  event.remote.write("echo server\r\n")
end

stream.listen(8000)

while Dyad.get_stream_count > 0
  Dyad.update
end

