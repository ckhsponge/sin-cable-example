require_relative '../application'
require 'aws-sdk-apigatewaymanagementapi'

def handler(event:, context:)
  puts "EVENT"
  puts(JSON.pretty_generate(event))
  
  domain = event['requestContext']['domainName']
  stage = event['requestContext']['stage']
  post_data = JSON.parse(event['body'])['data']
  
  client = Aws::ApiGatewayManagementApi::Client.new(
    endpoint: "https://#{domain}/#{stage}"
  )
  
  WebsocketConnection.find_each do |connection|
    begin
      client.post_to_connection(
        connection_id: connection.connection_id,
        data: post_data
      )
    rescue Aws::ApiGatewayManagementApi::Errors::GoneException
      connection.destroy
    end
  end
  
  puts "SEND_MESSAGE COMPLETING"
  { statusCode: 200, body: 'Data sent.' }
rescue => e
  { statusCode: 500, body: "Failed to send message: #{e.message}" }
end
