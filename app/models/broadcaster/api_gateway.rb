class Broadcaster::ApiGateway < ::Broadcaster

  def send_message(connection_id, path, data)
    puts "Broadcaster::ApiGateway send_message #{connection_id} #{path} #{data}"
    client = Aws::ApiGatewayManagementApi::Client.new(endpoint: ENV['API_GATEWAY_ENDPOINT'])
    client.post_to_connection(connection_id: connection_id, data: {path: path, data: data}.to_json)
    puts "Broadcaster::ApiGateway send_message DONE"
  rescue => e
    puts "ERROR: #{e.message}"
  end

end
