require_relative '../application'

def handler(event:, context:)
  puts "EVENT"
  puts(JSON.pretty_generate(event))
  connection_id = event['requestContext']['connectionId']
  
  WebsocketConnection.where(connection_id: connection_id).delete_all

  puts "DISCONNECT COMPLETING"
  { statusCode: 200, body: 'Disconnected.' }
rescue => e
  { statusCode: 500, body: "Failed to disconnect: #{e.message}" }
end
