require_relative '../application'
require 'aws-sdk-apigatewaymanagementapi'

def handler(event:, context:)
  puts "EVENT"
  puts(JSON.pretty_generate(event))
  connection_id = event['requestContext']['connectionId']
  route = event['requestContext']['routeKey']
  domain = event['requestContext']['domainName']
  stage = event['requestContext']['stage']

  if route == '$connect'
    connection = WebsocketConnection.connect(connection_id)
  elsif route == '$disconnect'
    WebsocketConnection.disconnect(connection_id)
  elsif route == 'ping' || route == 'hello'
    # Client sends this immediately after connecting
    client = Aws::ApiGatewayManagementApi::Client.new(endpoint: "https://#{domain}/#{stage}")
    client.post_to_connection(connection_id: connection_id, data: {type: 'welcome'}.to_json)
  elsif route == 'sendmessage'
    data = JSON.parse(event['body'])['data']
    WebsocketConnection.send_message(domain, stage, data)
  else
    puts "UNKNOWN ROUTE #{route}"
  end

  puts "WEBSOCKET COMPLETING"
  { statusCode: 200 }
rescue => e
  puts "ERROR: #{e.message}"
  puts e.backtrace
  { statusCode: 500, body: "Failed to connect: #{e.message}" }
end
