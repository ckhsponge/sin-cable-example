require_relative '../application'
require 'aws-sdk-apigatewaymanagementapi'

def handler(event:, context:)
  puts "EVENT"
  puts(JSON.pretty_generate(event))
  connection_id = event['requestContext']['connectionId']
  route = event['requestContext']['routeKey']
  # domain = event['requestContext']['domainName']
  # stage = event['requestContext']['stage']

  if route == '$connect'
    puts "$connect"
    WebsocketSubscription.connect(connection_id)
  elsif route == '$disconnect'
    puts "$disconnect"
    WebsocketSubscription.disconnect(connection_id)
  # elsif route == 'ping' || route == 'hello'
  #   # Client sends this immediately after connecting
  #   client = Aws::ApiGatewayManagementApi::Client.new(endpoint: "https://#{domain}/#{stage}")
  #   client.post_to_connection(connection_id: connection_id, data: {type: 'welcome'}.to_json)
  elsif route == 'perform'
    data = (JSON.parse(event['body'])['data'] || {}).with_indifferent_access
    path = data[:path]
    input = (data[:input] || {}).with_indifferent_access
    SocketController.handle_path(path, input)
  elsif route == 'subscribe'
    data = (JSON.parse(event['body'])['data'] || {}).with_indifferent_access
    path = data[:path]
    WebsocketSubscription.subscribe(path, connection_id)
  elsif route == 'unsubscribe'
    data = (JSON.parse(event['body'])['data'] || {}).with_indifferent_access
    path = data[:path]
    WebsocketSubscription.unsubscribe(path, connection_id)
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
