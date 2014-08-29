require 'dyad'

Dyad.init

serv = Dyad::Stream.new
serv.add_listener(:EVENT_ACCEPT) do |evt_accept|
  evt_accept.remote.add_listener(:EVENT_DATA) do |evt_data|
    evt_data.stream.write(evt_data.data)
  end
  evt_accept.remote.write("Echo server\r\n")
end

serv.listen(8000)

while Dyad.get_stream_count > 0
  Dyad.update
end

Dyad.shutdown
