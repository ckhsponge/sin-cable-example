require_relative '../application'
require 'aws-sdk-apigatewaymanagementapi'

def handler(event:, context:)
  puts "EVENT"
  puts(JSON.pretty_generate(event))
  connection_id = event['requestContext']['connectionId']
  route = event['requestContext']['routeKey']

  if route == '$connect'
    WebsocketConnection.connect(connection_id)
  elsif route == '$disconnect'
    WebsocketConnection.disconnect(connection_id)
  elsif route == 'sendmessage'
    domain = event['requestContext']['domainName']
    stage = event['requestContext']['stage']
    data = JSON.parse(event['body'])['data']
    WebsocketConnection.send_message(domain, stage, data)
  end

  puts "WEBSOCKET COMPLETING"
  { statusCode: 200, body: 'Connected.' }
rescue => e
  puts "ERROR: #{e.message}"
  puts e.backtrace
  { statusCode: 500, body: "Failed to connect: #{e.message}" }
end
