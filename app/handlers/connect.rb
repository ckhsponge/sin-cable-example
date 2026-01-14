require_relative '../application'

def handler(event:, context:)
  puts "EVENT"
  puts(JSON.pretty_generate(event))
  connection_id = event['requestContext']['connectionId']
  
  WebsocketConnection.find_or_create_by!(connection_id: connection_id)

  puts "CONNECT COMPLETING"
  { statusCode: 200, body: 'Connected.' }
rescue => e
  puts "ERROR: #{e.message}"
  puts e.backtrace
  { statusCode: 500, body: "Failed to connect: #{e.message}" }
end
