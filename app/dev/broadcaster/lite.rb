require "litecable"

class Broadcaster::Lite < ::Broadcaster
  def send_message(connection_id, path, data)
    puts "Broadcaster::Lite send_message #{connection_id} #{path} #{data}"
    LiteCable.broadcast LiteRouter::Channel.broadcast_channel(connection_id), { path: path, data: data }
    puts "Broadcaster::Lite send_message DONE"
  end
end
